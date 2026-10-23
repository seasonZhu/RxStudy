//
//  NCConnection.h
//  与 Mac 端的 socket 连接（收发协议帧）
//

#import <Foundation/Foundation.h>
#import "NCProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@class NCConnection;

@protocol NCConnectionDelegate <NSObject>
/// 收到一帧完整消息
- (void)connection:(NCConnection *)connection
    didReceiveType:(NCMessageType)type
              json:(nullable NSDictionary *)json
              data:(nullable NSData *)data;
- (void)connectionDidOpen:(NCConnection *)connection;
- (void)connection:(NCConnection *)connection didCloseWithError:(nullable NSError *)error;
@end

@interface NCConnection : NSObject

@property (nonatomic, weak) id<NCConnectionDelegate> delegate;
@property (nonatomic, readonly, getter=isOpen) BOOL open;

/// 以已连接的文件描述符构造（真机 USB 监听 accept 后使用）
- (instancetype)initWithSocket:(int)fd;

/// 主动连接 TCP 主机（模拟器 / macOS 使用）
+ (nullable instancetype)connectToHost:(NSString *)host port:(uint16_t)port;

- (void)open;
- (void)close;

/// 发送一帧
- (void)sendType:(NCMessageType)type json:(nullable NSDictionary *)json data:(nullable NSData *)data;

NS_ASSUME_NONNULL_END

@end
