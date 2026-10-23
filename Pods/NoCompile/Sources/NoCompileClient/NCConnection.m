//
//  NCConnection.m
//
//  线程约定：读循环独占 _ioQueue，写入在 _writeQueue 上串行执行。
//  关闭时只 shutdown 唤醒阻塞的读写，描述符本身由读循环退出后在写队列上关闭——
//  这样任何线程都不会在 close 之后再用到这个 fd 号（它可能已被 App 复用为别的文件，
//  在 guarded fd 上误操作会触发 EXC_GUARD 崩溃）。shutdown 与最终的 close(fd) 在同一把锁内
//  互斥执行，并以 _fdClosed 标记，避免 close 线程被抢占后对已关闭、已被复用的 fd 号再 shutdown。
//

#if DEBUG || NOCOMPILE_FORCE_ENABLE

#import "NCConnection.h"
#include <sys/socket.h>
#include <netinet/in.h>
#include <netinet/tcp.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#include <stdatomic.h>

@implementation NCConnection {
    int _fd;
    dispatch_queue_t _ioQueue;      // 读循环（长期阻塞）
    dispatch_queue_t _writeQueue;   // 写（独立队列，避免被读循环饿死）
    atomic_bool _open;
    /// open 是否调用过：没调用过的连接由 dealloc 负责关闭描述符
    atomic_bool _started;
    /// 保护 shutdown 与 close(fd)，见文件头说明
    NSLock *_fdLock;
    BOOL _fdClosed;
}

- (instancetype)initWithSocket:(int)fd {
    self = [super init];
    if (self) {
        _fd = fd;
        atomic_init(&_open, false);
        atomic_init(&_started, false);
        _fdLock = [NSLock new];
        _ioQueue = dispatch_queue_create("com.nocompile.connection.read", DISPATCH_QUEUE_SERIAL);
        _writeQueue = dispatch_queue_create("com.nocompile.connection.write", DISPATCH_QUEUE_SERIAL);
        [self configureSocket];
    }
    return self;
}

- (void)dealloc {
    if (!atomic_load(&_started) && _fd >= 0) {
        close(_fd);
    }
}

+ (instancetype)connectToHost:(NSString *)host port:(uint16_t)port {
    int fd = socket(AF_INET, SOCK_STREAM, 0);
    if (fd < 0) {
        return nil;
    }
    struct sockaddr_in addr = {0};
    addr.sin_family = AF_INET;
    addr.sin_port = htons(port);
    if (inet_pton(AF_INET, host.UTF8String, &addr.sin_addr) != 1) {
        close(fd);
        return nil;
    }
    if (connect(fd, (struct sockaddr *)&addr, sizeof(addr)) != 0) {
        close(fd);
        return nil;
    }
    return [[self alloc] initWithSocket:fd];
}

- (void)configureSocket {
    int on = 1;
    setsockopt(_fd, IPPROTO_TCP, TCP_NODELAY, &on, sizeof(on));
    setsockopt(_fd, SOL_SOCKET, SO_NOSIGPIPE, &on, sizeof(on));
    // TCP 保活：Wi-Fi 连接时 Mac 休眠、断网或换网络不会发来 FIN，读循环会永远阻塞、不再重连。
    // 空闲 30 秒后开始探测，每 10 秒一次，连续 3 次无应答即判定断开（约 1 分钟）。
    // 由内核应答探测，App 停在断点时连接也不会被误判断开。非 TCP 套接字（单元测试的 socketpair）设置失败无影响
    setsockopt(_fd, SOL_SOCKET, SO_KEEPALIVE, &on, sizeof(on));
    int idle = 30;
    int interval = 10;
    int count = 3;
    setsockopt(_fd, IPPROTO_TCP, TCP_KEEPALIVE, &idle, sizeof(idle));
    setsockopt(_fd, IPPROTO_TCP, TCP_KEEPINTVL, &interval, sizeof(interval));
    setsockopt(_fd, IPPROTO_TCP, TCP_KEEPCNT, &count, sizeof(count));
}

- (BOOL)isOpen {
    return atomic_load(&_open);
}

- (void)open {
    bool expected = false;
    if (!atomic_compare_exchange_strong(&_started, &expected, true)) {
        return;
    }
    atomic_store(&_open, true);
    [self.delegate connectionDidOpen:self];
    dispatch_async(_ioQueue, ^{
        [self readLoop];
    });
}

- (void)close {
    bool expected = true;
    if (!atomic_compare_exchange_strong(&_open, &expected, false)) {
        return;
    }
    // 只唤醒阻塞中的读写；描述符由读循环退出时关闭
    [_fdLock lock];
    if (!_fdClosed) {
        shutdown(_fd, SHUT_RDWR);
    }
    [_fdLock unlock];
}

#pragma mark - 读

/// 阻塞读满 length 字节；失败返回 NO
- (BOOL)readFully:(void *)buffer length:(size_t)length {
    size_t received = 0;
    uint8_t *cursor = buffer;
    while (received < length) {
        ssize_t n = read(_fd, cursor + received, length - received);
        if (n < 0 && errno == EINTR) {
            continue;
        }
        if (n <= 0) {
            return NO;
        }
        received += (size_t)n;
    }
    return YES;
}

- (void)readLoop {
    NSString *reason = @"连接已断开";
    while (self.isOpen) {
        NCFrameHeader header = {0};
        if (![self readFully:&header length:sizeof(header)]) {
            break;
        }
        if (header.magic != NC_PROTOCOL_MAGIC) {
            reason = @"协议魔数不匹配";
            break;
        }
        if (header.jsonLength > NC_MAX_JSON_LENGTH || header.dataLength > NC_MAX_DATA_LENGTH) {
            reason = @"帧长度超出上限";
            break;
        }
        NSDictionary *json = nil;
        NSData *data = nil;
        if (header.jsonLength > 0) {
            NSMutableData *jsonData = [NSMutableData dataWithLength:header.jsonLength];
            if (![self readFully:jsonData.mutableBytes length:header.jsonLength]) {
                break;
            }
            id object = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:NULL];
            json = [object isKindOfClass:NSDictionary.class] ? object : nil;
        }
        if (header.dataLength > 0) {
            NSMutableData *payload = [NSMutableData dataWithLength:(NSUInteger)header.dataLength];
            if (!payload || ![self readFully:payload.mutableBytes length:(size_t)header.dataLength]) {
                break;
            }
            data = payload;
        }
        @autoreleasepool {
            [self.delegate connection:self didReceiveType:(NCMessageType)header.type json:json data:data];
        }
    }
    [self close];
    NSError *error = [NSError errorWithDomain:@"NoCompile" code:-1
                                     userInfo:@{ NSLocalizedDescriptionKey: reason }];
    [self.delegate connection:self didCloseWithError:error];
    // 写队列上排在前面的写入会因 shutdown 立即失败，之后再关闭描述符
    dispatch_async(_writeQueue, ^{
        [self->_fdLock lock];
        if (!self->_fdClosed) {
            self->_fdClosed = YES;
            close(self->_fd);
        }
        [self->_fdLock unlock];
    });
}

#pragma mark - 写

- (void)sendType:(NCMessageType)type json:(NSDictionary *)json data:(NSData *)data {
    if (!self.isOpen) {
        return;
    }
    NSData *jsonData = nil;
    if (json) {
        // 含非 JSON 类型（NSDate、NSData 等）时 dataWithJSONObject: 会抛异常让宿主 App 崩溃，先校验，不合法就丢弃整帧
        if (![NSJSONSerialization isValidJSONObject:json]) {
            NSLog(@"[NoCompile] 消息含无法序列化为 JSON 的内容，已丢弃（类型 %u）", (unsigned)type);
            return;
        }
        jsonData = [NSJSONSerialization dataWithJSONObject:json options:0 error:NULL];
    }
    NCFrameHeader header = {0};
    header.magic = NC_PROTOCOL_MAGIC;
    header.type = type;
    header.jsonLength = (uint32_t)jsonData.length;
    header.dataLength = (uint64_t)data.length;

    NSMutableData *frame = [NSMutableData dataWithBytes:&header length:sizeof(header)];
    if (jsonData) {
        [frame appendData:jsonData];
    }
    if (data) {
        [frame appendData:data];
    }
    dispatch_async(_writeQueue, ^{
        [self writeFully:frame];
    });
}

/// 在写队列上执行。连接已关闭时不再写入（描述符可能即将或已经被关闭）
- (void)writeFully:(NSData *)frame {
    const uint8_t *bytes = frame.bytes;
    size_t total = frame.length;
    size_t sent = 0;
    while (sent < total && self.isOpen) {
        ssize_t n = write(_fd, bytes + sent, total - sent);
        if (n < 0 && errno == EINTR) {
            continue;
        }
        if (n <= 0) {
            [self close];
            return;
        }
        sent += (size_t)n;
    }
}

@end

#endif
