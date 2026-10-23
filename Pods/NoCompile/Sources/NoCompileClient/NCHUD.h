//
//  NCHUD.h
//  注入状态浮层（iOS / tvOS 显示小胶囊，macOS 暂为日志）
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NCHUD : NSObject
/// state: 0 成功 / 1 进行中 / 2 失败
+ (void)showStatus:(NSString *)message state:(NSInteger)state;
@end

NS_ASSUME_NONNULL_END
