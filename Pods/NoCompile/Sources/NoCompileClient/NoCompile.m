//
//  NoCompile.m
//  客户端入口与连接管理
//

#import "NoCompile.h"

NSNotificationName const NoCompileDidInjectNotification = @"NoCompileDidInjectNotification";
NSNotificationName const NoCompileInjectionBundleNotification = @"INJECTION_BUNDLE_NOTIFICATION";
NSString * const NoCompileInjectedFilesKey = @"files";

#if DEBUG || NOCOMPILE_FORCE_ENABLE

#import "NCConnection.h"
#import "NCInjector.h"
#import "NCResources.h"
#import "NCSwizzleGuard.h"
#import "NCLog.h"
#import "NCHUD.h"
#include <mach-o/dyld.h>
#include <mach-o/loader.h>
#include <dlfcn.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <unistd.h>
#include <errno.h>
#include <sys/utsname.h>
#if TARGET_OS_IOS || TARGET_OS_TV
#import <UIKit/UIKit.h>
#endif

@interface NoCompile () <NCConnectionDelegate>
+ (instancetype)shared;
- (void)startWithHost:(nullable NSString *)host;
/// 当前连接：重连线程、监听线程、读写线程与主线程都会访问，必须 atomic
@property (atomic, strong) NCConnection *connection;
@property (nonatomic, copy) NSString *host;
@property (atomic) BOOL started;
/// 设备信息（设备标识、名称、系统版本），启动时在主线程采集，握手时上报
@property (atomic, copy) NSDictionary *deviceInfo;
@end

@implementation NoCompile

static BOOL gAutoReloadViewControllers = NO;
static BOOL gPreserveStaticState = YES;
static BOOL gShowsHUD = YES;
static BOOL gSuppressSwizzlingDuringLoad = YES;
static NSUInteger gInjectionCount = 0;

+ (BOOL)autoReloadViewControllers { return gAutoReloadViewControllers; }
+ (void)setAutoReloadViewControllers:(BOOL)value { gAutoReloadViewControllers = value; }
+ (BOOL)preserveStaticState { return gPreserveStaticState; }
+ (void)setPreserveStaticState:(BOOL)value { gPreserveStaticState = value; }
+ (BOOL)showsHUD { return gShowsHUD; }
+ (void)setShowsHUD:(BOOL)value { gShowsHUD = value; }
+ (BOOL)suppressSwizzlingDuringLoad { return gSuppressSwizzlingDuringLoad; }
+ (void)setSuppressSwizzlingDuringLoad:(BOOL)value { gSuppressSwizzlingDuringLoad = value; }
+ (NSUInteger)injectionCount { return gInjectionCount; }

+ (instancetype)shared {
    static NoCompile *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [NoCompile new];
    });
    return instance;
}

+ (BOOL)isConnected {
    return [self shared].connection.isOpen;
}

+ (void)start {
    [[self shared] startWithHost:nil];
}

+ (void)startWithHost:(NSString *)host {
    [[self shared] startWithHost:host];
}

- (void)startWithHost:(NSString *)host {
    if (self.started) {
        return;
    }
    self.started = YES;
    self.host = host;
    self.deviceInfo = [self collectDeviceInfo];

    NCSwizzleGuardInstall();
    NCLogSetForwarder(^(NCLogLevel level, NSString *message) {
        [self forwardLog:level message:message];
    });

#if TARGET_OS_SIMULATOR || TARGET_OS_OSX || TARGET_OS_MACCATALYST
    // 模拟器 / macOS / Mac Catalyst：与 Mac 端在同一台机器上，主动连接本机 Mac 端
    [self connectLoop];
#else
    // 真机：监听回环端口，等待 Mac 经 usbmuxd 连入；若设置了 host 则同时尝试 Wi-Fi
    [self startDeviceListener];
    if (host.length > 0) {
        [self connectLoop];
    }
#endif
}

#pragma mark - 连接（模拟器 / macOS / 真机 Wi-Fi）

- (void)connectLoop {
    NSString *host = self.host.length > 0 ? self.host : @"127.0.0.1";
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0), ^{
        while (self.started) {
            NCConnection *current = self.connection;
            if (!current.isOpen) {
                NCConnection *connection = [NCConnection connectToHost:host port:NC_MAC_PORT];
                if (connection) {
                    connection.delegate = self;
                    @synchronized (self) {
                        self.connection = connection;
                    }
                    [connection open];
                }
            }
            sleep(2); // 每 2 秒检查一次，断开后重连
        }
    });
}

#pragma mark - 设备监听（真机 USB）

- (void)startDeviceListener {
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0), ^{
        BOOL reportedBindFailure = NO;
        BOOL reportedListening = NO;
        while (self.started) {
            int fd = [self openDeviceListenSocket];
            if (fd < 0) {
                // 端口被同一台设备上另一个接入了 NoCompile 的 App 占用：稍后重试，它退出后即可接管
                if (!reportedBindFailure) {
                    reportedBindFailure = YES;
                    NSLog(@"[NoCompile] ⚠️ 无法监听端口 %d（errno %d），可能被设备上另一个接入 NoCompile 的 App 占用，将持续重试",
                          NC_DEVICE_PORT, errno);
                }
                sleep(3);
                continue;
            }
            reportedBindFailure = NO;
            // 只在首次监听成功时提示，便于排查「真机连不上」时确认客户端已在设备上工作
            if (!reportedListening) {
                reportedListening = YES;
                NSLog(@"[NoCompile] 正在监听 127.0.0.1:%d，等待 Mac 端经 USB（usbmuxd）连入", NC_DEVICE_PORT);
            }
            [self acceptDeviceConnectionsOn:fd];
            close(fd);
            // 监听 socket 失效（如 App 在后台被挂起后）：稍后重建
            sleep(1);
        }
    });
}

/// 在回环地址上监听设备端口，失败返回 -1
- (int)openDeviceListenSocket {
    int fd = socket(AF_INET, SOCK_STREAM, 0);
    if (fd < 0) {
        return -1;
    }
    int on = 1;
    setsockopt(fd, SOL_SOCKET, SO_REUSEADDR, &on, sizeof(on));
    struct sockaddr_in addr = {0};
    addr.sin_family = AF_INET;
    addr.sin_port = htons(NC_DEVICE_PORT);
    addr.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
    if (bind(fd, (struct sockaddr *)&addr, sizeof(addr)) != 0 || listen(fd, 2) != 0) {
        int saved = errno;
        close(fd);
        errno = saved;
        return -1;
    }
    return fd;
}

/// 接受 Mac 经 usbmuxd 发起的连接；监听 socket 出错时返回
- (void)acceptDeviceConnectionsOn:(int)fd {
    while (self.started) {
        int client = accept(fd, NULL, NULL);
        if (client < 0) {
            if (errno == EINTR || errno == ECONNABORTED) {
                continue;
            }
            return;
        }
        NCConnection *connection = [[NCConnection alloc] initWithSocket:client];
        connection.delegate = self;
        // 新连接取代旧连接（Mac 端重启引擎后会重新连入），旧连接关闭，避免两条连接重复执行注入
        NCConnection *previous = nil;
        @synchronized (self) {
            previous = self.connection;
            self.connection = connection;
        }
        [previous close];
        [connection open];
    }
}

#pragma mark - NCConnectionDelegate

- (void)connectionDidOpen:(NCConnection *)connection {
    [self sendHelloOn:connection];
}

- (void)connection:(NCConnection *)connection didCloseWithError:(NSError *)error {
    // 比较与清空要原子地完成，否则可能把刚建立的新连接清掉
    @synchronized (self) {
        if (self.connection == connection) {
            self.connection = nil;
        }
    }
}

- (void)connection:(NCConnection *)connection
    didReceiveType:(NCMessageType)type
              json:(NSDictionary *)json
              data:(NSData *)data {
    switch (type) {
        case NCMessageTypeInject:
            [self handleInject:json data:data from:connection];
            break;
        case NCMessageTypeResource:
            [self handleResource:json data:data from:connection];
            break;
        case NCMessageTypeStatus:
            [self handleStatus:json];
            break;
        case NCMessageTypeHelloAck:
            NCLogLocal(NCLogLevelSuccess, @"🔌 已连接到 NoCompile Mac 端（%@）", json[@"clientVersion"] ?: @"未知版本");
            [self applyConfig:json[@"config"]];
            break;
        case NCMessageTypeConfig:
            [self applyConfig:json[@"config"]];
            break;
        case NCMessageTypePing:
            [connection sendType:NCMessageTypePong json:nil data:nil];
            break;
        default:
            break;
    }
}

#pragma mark - 消息处理

/// 镜像的 LC_UUID
static NSString *NCImageUUID(const struct mach_header *header) {
    if (!header || header->magic != MH_MAGIC_64) {
        return nil;
    }
    const uint8_t *cursor = (const uint8_t *)((const struct mach_header_64 *)header + 1);
    for (uint32_t i = 0; i < header->ncmds; i++) {
        const struct load_command *command = (const struct load_command *)cursor;
        if (command->cmd == LC_UUID) {
            const struct uuid_command *uuidCommand = (const struct uuid_command *)command;
            return [[NSUUID alloc] initWithUUIDBytes:uuidCommand->uuid].UUIDString;
        }
        cursor += command->cmdsize;
    }
    return nil;
}

/// 客户端自身所在镜像的路径与 LC_UUID。bundle 方式接入时，Mac 端据此判断 App 包内的 bundle 是否与当前 Mac 端随附的一致
- (void)clientImagePath:(NSString **)outPath uuid:(NSString **)outUUID {
    Dl_info info;
    if (dladdr((__bridge const void *)NoCompile.class, &info) == 0 || info.dli_fbase == NULL) {
        return;
    }
    if (info.dli_fname) {
        *outPath = @(info.dli_fname);
    }
    *outUUID = NCImageUUID((const struct mach_header *)info.dli_fbase) ?: @"";
}

/// App 主程序与 <可执行文件>.debug.dylib（Xcode 16 起 Debug 构建的代码所在）：LC_UUID → 运行时 slide。
/// Mac 端用 UUID 与 DerivedData 中的构建产物比对，判断 App 是否由当前工程构建、构建于何时；
/// slide 用来把产物符号表里的地址换算成进程内地址，桥接 App 未导出的符号
- (NSDictionary<NSString *, NSNumber *> *)appImageSlides {
    NSString *executable = NSBundle.mainBundle.executablePath.lastPathComponent;
    NSString *bundleName = NSBundle.mainBundle.bundlePath.lastPathComponent;
    if (executable.length == 0) {
        return @{};
    }
    NSString *debugDylib = [executable stringByAppendingString:@".debug.dylib"];
    NSMutableDictionary<NSString *, NSNumber *> *slides = [NSMutableDictionary dictionary];
    uint32_t count = _dyld_image_count();
    for (uint32_t i = 0; i < count; i++) {
        const char *name = _dyld_get_image_name(i);
        if (!name) {
            continue;
        }
        NSString *path = @(name);
        NSString *file = path.lastPathComponent;
        if (![path containsString:bundleName] || !([file isEqualToString:executable] || [file isEqualToString:debugDylib])) {
            continue;
        }
        NSString *uuid = NCImageUUID(_dyld_get_image_header(i));
        if (uuid) {
            slides[uuid] = @((long long)_dyld_get_image_vmaddr_slide(i));
        }
    }
    return slides;
}

/// 设备标识、名称与系统版本（在主线程调用）
- (NSDictionary *)collectDeviceInfo {
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
#if TARGET_OS_SIMULATOR
    NSDictionary<NSString *, NSString *> *env = NSProcessInfo.processInfo.environment;
    info[@"deviceID"] = env[@"SIMULATOR_UDID"] ?: @"";
    info[@"deviceName"] = env[@"SIMULATOR_DEVICE_NAME"] ?: UIDevice.currentDevice.name;
    NSString *version = env[@"SIMULATOR_RUNTIME_VERSION"] ?: UIDevice.currentDevice.systemVersion;
    info[@"systemVersion"] = [NSString stringWithFormat:@"%@ %@", UIDevice.currentDevice.systemName, version];
#elif TARGET_OS_OSX || TARGET_OS_MACCATALYST
    NSOperatingSystemVersion version = NSProcessInfo.processInfo.operatingSystemVersion;
    info[@"deviceID"] = @"local";
    info[@"systemVersion"] = [NSString stringWithFormat:@"macOS %ld.%ld", (long)version.majorVersion, (long)version.minorVersion];
#else
    UIDevice *device = UIDevice.currentDevice;
    info[@"deviceID"] = device.identifierForVendor.UUIDString ?: @"";
    info[@"deviceName"] = device.name ?: @"";
    info[@"systemVersion"] = [NSString stringWithFormat:@"%@ %@", device.systemName, device.systemVersion];
#endif
    return info;
}

- (void)sendHelloOn:(NCConnection *)connection {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *imagePath = @"";
    NSString *imageUUID = @"";
    [self clientImagePath:&imagePath uuid:&imageUUID];
    NSMutableDictionary *hello = [@{
        @"protocol": @(NC_PROTOCOL_VERSION),
        @"clientVersion": NC_CLIENT_VERSION,
        @"clientRevision": @(NC_CLIENT_REVISION),
        @"clientImage": imagePath ?: @"",
        @"clientUUID": imageUUID ?: @"",
        @"bundleID": NSBundle.mainBundle.bundleIdentifier ?: @"",
        @"bundlePath": NSBundle.mainBundle.bundlePath ?: @"",
        @"executable": NSBundle.mainBundle.executablePath ?: @"",
        @"machine": @(systemInfo.machine),
#if TARGET_OS_SIMULATOR
        @"platform": @"simulator",
#elif TARGET_OS_MACCATALYST
        // Mac Catalyst：TARGET_OS_OSX 为 0、TARGET_OS_IOS 为 1，必须先于真机分支判断
        @"platform": @"maccatalyst",
#elif TARGET_OS_OSX
        @"platform": @"macosx",
#else
        @"platform": @"device",
#endif
        @"home": NSHomeDirectory(),
        @"tmp": NSTemporaryDirectory(),
        @"pid": @(getpid()),
    } mutableCopy];
    NSDictionary<NSString *, NSNumber *> *slides = [self appImageSlides];
    hello[@"imageUUIDs"] = slides.allKeys;
    hello[@"imageSlides"] = slides;
    [hello addEntriesFromDictionary:self.deviceInfo ?: @{}];
    [connection sendType:NCMessageTypeHello json:hello data:nil];
}

/// 应用 Mac 端下发的偏好设置
- (void)applyConfig:(NSDictionary *)config {
    if (![config isKindOfClass:NSDictionary.class]) {
        return;
    }
    NSNumber *autoReload = config[@"autoReloadViewControllers"];
    if (autoReload) {
        gAutoReloadViewControllers = autoReload.boolValue;
    }
    NSNumber *preserveStatics = config[@"preserveStaticState"];
    if (preserveStatics) {
        gPreserveStaticState = preserveStatics.boolValue;
    }
    NSNumber *showsHUD = config[@"showsHUD"];
    if (showsHUD) {
        gShowsHUD = showsHUD.boolValue;
    }
    NSNumber *suppress = config[@"suppressSwizzlingDuringLoad"];
    if (suppress) {
        gSuppressSwizzlingDuringLoad = suppress.boolValue;
    }
}

- (void)handleStatus:(NSDictionary *)json {
    NSString *message = json[@"message"];
    NSInteger state = [json[@"state"] integerValue];
    if (gShowsHUD && message) {
        [NCHUD showStatus:message state:state];
    }
}

/// 取字典里指定类型的值，类型不符时返回 nil（Mac 端数据异常时不至于 unrecognized selector）
static id NCTyped(NSDictionary *json, NSString *key, Class cls) {
    id value = [json isKindOfClass:NSDictionary.class] ? json[key] : nil;
    return [value isKindOfClass:cls] ? value : nil;
}

- (void)handleInject:(NSDictionary *)json data:(NSData *)data from:(NCConnection *)connection {
    NSString *requestedName = NCTyped(json, @"dylibName", NSString.class);
    // 只取文件名，防止路径穿越写到 tmp 目录之外
    NSString *dylibName = requestedName.lastPathComponent.length > 0 ? requestedName.lastPathComponent : @"nocompile_injection.dylib";
    NSArray<NSString *> *sourceFiles = NCTyped(json, @"sourceFiles", NSArray.class) ?: @[];
    for (id file in sourceFiles) {
        if (![file isKindOfClass:NSString.class]) {
            sourceFiles = @[];
            break;
        }
    }
    NSString *localPath = NCTyped(json, @"localPath", NSString.class);
    BOOL isNewFile = [NCTyped(json, @"newFile", NSNumber.class) boolValue];
    // 符号桥接 dylib（可选）：模拟器 / macOS 给路径；真机随帧传输，位于数据开头，长度为 shimLength
    NSString *shimName = [NCTyped(json, @"shimName", NSString.class) lastPathComponent];
    NSString *shimLocalPath = NCTyped(json, @"shimLocalPath", NSString.class);
    NSUInteger shimLength = [NCTyped(json, @"shimLength", NSNumber.class) unsignedIntegerValue];
    NSString *shimPath = nil;

    NSString *dylibPath;
    if (localPath.length > 0 && [NSFileManager.defaultManager fileExistsAtPath:localPath]) {
        // 模拟器 / macOS：Mac 端已把 dylib 写到共享文件系统，直接使用路径
        dylibPath = localPath;
        if (shimLocalPath.length > 0 && [NSFileManager.defaultManager fileExistsAtPath:shimLocalPath]) {
            shimPath = shimLocalPath;
        }
    } else if (data.length > shimLength) {
        // 真机：dylib 随帧传输，落盘到可执行目录
        NSData *dylibData = data;
        if (shimLength > 0 && shimName.length > 0) {
            shimPath = [NSTemporaryDirectory() stringByAppendingPathComponent:shimName];
            if (![[data subdataWithRange:NSMakeRange(0, shimLength)] writeToFile:shimPath atomically:YES]) {
                [self sendInjectResult:NO message:[NSString stringWithFormat:@"无法写入符号桥接 dylib（%@），设备存储空间可能不足", shimPath]
                                source:sourceFiles summary:nil refreshed:nil pending:nil on:connection];
                return;
            }
            dylibData = [data subdataWithRange:NSMakeRange(shimLength, data.length - shimLength)];
        }
        dylibPath = [NSTemporaryDirectory() stringByAppendingPathComponent:dylibName];
        // 写入失败（如存储空间不足）时直接报告，否则 dlopen 报的"找不到镜像"会误导排查方向
        if (![dylibData writeToFile:dylibPath atomically:YES]) {
            [self sendInjectResult:NO message:[NSString stringWithFormat:@"无法写入 dylib（%@），设备存储空间可能不足", dylibPath]
                            source:sourceFiles summary:nil refreshed:nil pending:nil on:connection];
            return;
        }
    } else {
        [self sendInjectResult:NO message:@"注入请求缺少 dylib" source:sourceFiles summary:nil refreshed:nil pending:nil on:connection];
        return;
    }

    if (gShowsHUD) {
        [NCHUD showStatus:@"注入中…" state:1];
    }

    NCInjectResult *result = [NCInjector injectDylibAtPath:dylibPath
                                               sourceFiles:sourceFiles
                                                 isNewFile:isNewFile
                                            symbolShimPath:shimPath];
    BOOL ok = result.status == NCInjectStatusSuccess;
    NSString *fileName = sourceFiles.firstObject.lastPathComponent ?: dylibName;
    NSString *hud;
    NSString *summary = nil;
    if (ok) {
        gInjectionCount++;
        // 替换统计：Mac 端把它拼进同一行结果日志，这里只打印到本地控制台，不再转发，避免 Mac 端日志重复
        NSMutableArray<NSString *> *parts = [NSMutableArray array];
        if (result.objcMethodsReplaced > 0) {
            [parts addObject:[NSString stringWithFormat:@"ObjC 方法 %lu", (unsigned long)result.objcMethodsReplaced]];
        }
        if (result.swiftSlotsPatched > 0) {
            [parts addObject:[NSString stringWithFormat:@"Swift 槽位 %lu", (unsigned long)result.swiftSlotsPatched]];
        }
        if (result.symbolsRebound > 0) {
            [parts addObject:[NSString stringWithFormat:@"函数重绑 %lu", (unsigned long)result.symbolsRebound]];
        }
        if (result.categoriesAttached > 0) {
            [parts addObject:[NSString stringWithFormat:@"分类 %lu", (unsigned long)result.categoriesAttached]];
        }
        summary = [parts componentsJoinedByString:@"，"];
        NSString *refreshed = result.refreshedControllers.count > 0
            ? [NSString stringWithFormat:@"，已刷新 %@", [result.refreshedControllers componentsJoinedByString:@"、"]]
            : @"";
        NCLogLocal(NCLogLevelSuccess, @"⚡ %@%@ 已生效（%@）%@", fileName, isNewFile ? @"（新增文件）" : @"",
                   summary.length > 0 ? summary : @"无替换", refreshed);
        hud = result.warnings.count > 0
            ? [NSString stringWithFormat:@"%@ 部分改动需重新运行 App", fileName]
            : [self successHUDForFile:fileName pending:result.pendingControllers];
    } else {
        NCLogLocal(NCLogLevelError, @"⚡ %@ 注入失败：%@", fileName, result.message);
        hud = [NSString stringWithFormat:@"%@ 注入失败", fileName];
    }
    if (gShowsHUD) {
        [NCHUD showStatus:hud state:ok ? (result.warnings.count > 0 ? 2 : 0) : 2];
    }
    [self sendInjectResult:ok
                   message:result.message
                    source:sourceFiles
                   summary:summary
                 refreshed:result.refreshedControllers
                   pending:result.pendingControllers
                        on:connection];
}

/// 成功提示：有未自动重建的已加载页面时，打印日志并在浮层提示用户退出页面后重新进入
- (NSString *)successHUDForFile:(NSString *)fileName pending:(NSArray<NSString *> *)pending {
    if (pending.count == 0) {
        return [NSString stringWithFormat:@"%@ 已生效", fileName];
    }
    // Mac 端会把待重进页面拼进结果日志，这里只打印到本地
    NCLogLocal(NCLogLevelWarning, @"%@ 已加载，未自动重建：退出该页面后重新进入即可看到改动",
               [pending componentsJoinedByString:@"、"]);
    return [NSString stringWithFormat:@"%@ 已生效，退出页面重进即可看到", fileName];
}

/// 资源更新：storyboard / xib 编译产物与图片
- (void)handleResource:(NSDictionary *)json data:(NSData *)data from:(NCConnection *)connection {
    NSString *source = NCTyped(json, @"source", NSString.class) ?: @"";
    NSString *fileName = source.lastPathComponent.length > 0 ? source.lastPathComponent : (NCTyped(json, @"name", NSString.class) ?: @"资源");
    if (gShowsHUD) {
        [NCHUD showStatus:@"更新资源…" state:1];
    }
    NCResourceResult *result = [NCResources applyPackage:json data:data];
    NSString *hud;
    if (result.ok) {
        gInjectionCount++;
        NSString *refreshed = result.refreshedControllers.count > 0
            ? [NSString stringWithFormat:@"，已刷新 %@", [result.refreshedControllers componentsJoinedByString:@"、"]]
            : @"";
        NCLogLocal(NCLogLevelSuccess, @"🖼 %@ 资源已更新%@", fileName, refreshed);
        hud = [self successHUDForFile:fileName pending:result.pendingControllers];
    } else {
        NCLogLocal(NCLogLevelError, @"🖼 %@ 资源更新失败：%@", fileName, result.message);
        hud = [NSString stringWithFormat:@"%@ 更新失败", fileName];
    }
    if (gShowsHUD) {
        [NCHUD showStatus:hud state:result.ok ? 0 : 2];
    }
    [connection sendType:NCMessageTypeResourceResult
                         json:@{ @"ok": @(result.ok),
                                 @"message": result.message ?: @"",
                                 @"sourceFiles": @[source],
                                 @"refreshed": result.refreshedControllers ?: @[],
                                 @"pending": result.pendingControllers ?: @[] }
                         data:nil];
}

/// 结果回给发来请求的连接（同时存在多条连接时不会回错）
- (void)sendInjectResult:(BOOL)ok
                 message:(NSString *)message
                  source:(NSArray<NSString *> *)source
                 summary:(NSString *)summary
               refreshed:(NSArray<NSString *> *)refreshed
                 pending:(NSArray<NSString *> *)pending
                      on:(NCConnection *)connection {
    [connection sendType:NCMessageTypeInjectResult
                    json:@{ @"ok": @(ok),
                            @"message": message ?: @"",
                            @"summary": summary ?: @"",
                            @"sourceFiles": source ?: @[],
                            @"refreshed": refreshed ?: @[],
                            @"pending": pending ?: @[] }
                    data:nil];
}

- (void)forwardLog:(NCLogLevel)level message:(NSString *)message {
    [self.connection sendType:NCMessageTypeLog
                         json:@{ @"level": @(level), @"message": message }
                         data:nil];
}

@end

#endif
