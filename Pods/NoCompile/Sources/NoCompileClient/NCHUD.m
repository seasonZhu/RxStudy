//
//  NCHUD.m
//

#if DEBUG || NOCOMPILE_FORCE_ENABLE

#import "NCHUD.h"

#if __has_include(<UIKit/UIKit.h>)
#import <UIKit/UIKit.h>

@interface NCHUD ()
/// 圆角背景容器：文字多行时整体增高，左右留出内边距
@property (nonatomic, strong) UIView *container;
@property (nonatomic, strong) UILabel *label;
@end

@implementation NCHUD

/// 文字与容器边缘的间距
static const CGFloat NCHUDHorizontalPadding = 12;
static const CGFloat NCHUDVerticalPadding = 7;
/// 浮层距屏幕左右的最小间距，以及在大屏上的最大宽度
static const CGFloat NCHUDScreenMargin = 16;
static const CGFloat NCHUDMaxWidth = 420;

+ (instancetype)shared {
    static NCHUD *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [NCHUD new];
    });
    return instance;
}

+ (void)showStatus:(NSString *)message state:(NSInteger)state {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[self shared] present:message state:state];
    });
}

- (void)setupViewsIfNeeded {
    if (self.container) {
        return;
    }
    UIView *container = [UIView new];
    container.layer.cornerRadius = 12;
    container.layer.masksToBounds = YES;
    container.userInteractionEnabled = NO;

    UILabel *label = [UILabel new];
    label.font = [UIFont monospacedDigitSystemFontOfSize:12 weight:UIFontWeightSemibold];
    label.textColor = UIColor.whiteColor;
    label.textAlignment = NSTextAlignmentCenter;
    // 长文案（文件名 + 提示）自动换行，完整显示
    label.numberOfLines = 0;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    [container addSubview:label];

    self.container = container;
    self.label = label;
}

- (void)present:(NSString *)message state:(NSInteger)state {
    UIWindow *window = [self keyWindow];
    if (!window) {
        return;
    }
    [self setupViewsIfNeeded];
    if (self.container.superview != window) {
        [window addSubview:self.container];
    }
    [window bringSubviewToFront:self.container];

    UIColor *background;
    switch (state) {
        case 0: background = [UIColor colorWithRed:0.20 green:0.70 blue:0.35 alpha:0.95]; break; // 成功
        case 2: background = [UIColor colorWithRed:0.85 green:0.25 blue:0.25 alpha:0.95]; break; // 失败
        default: background = [UIColor colorWithRed:0.90 green:0.65 blue:0.15 alpha:0.95]; break; // 进行中
    }
    self.container.backgroundColor = background;
    self.label.text = [@"⚡ " stringByAppendingString:message];

    // 宽度随文字自适应，超出屏幕宽度时换行，高度随行数增长
    CGRect bounds = window.bounds;
    UIEdgeInsets safeArea = window.safeAreaInsets;
    CGFloat available = bounds.size.width - safeArea.left - safeArea.right - NCHUDScreenMargin * 2;
    CGFloat maxWidth = MAX(MIN(available, NCHUDMaxWidth), 120);
    CGSize textSize = [self.label sizeThatFits:CGSizeMake(maxWidth - NCHUDHorizontalPadding * 2, CGFLOAT_MAX)];
    CGFloat width = MIN(maxWidth, ceil(textSize.width) + NCHUDHorizontalPadding * 2);
    CGFloat height = MAX(28, ceil(textSize.height) + NCHUDVerticalPadding * 2);
    CGFloat top = safeArea.top + 8;
    CGFloat left = safeArea.left + (bounds.size.width - safeArea.left - safeArea.right - width) / 2;
    self.container.frame = CGRectMake(left, top, width, height);
    self.container.layer.cornerRadius = MIN(12, height / 2);
    self.label.frame = CGRectInset(self.container.bounds, NCHUDHorizontalPadding, NCHUDVerticalPadding);
    self.container.alpha = 1;

    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(dismiss) object:nil];
    if (state != 1) {
        // 文案越长停留越久，便于读完；失败提示再多停一会儿
        NSTimeInterval delay = MIN(6.0, 1.5 + message.length * 0.04) + (state == 2 ? 1.0 : 0);
        [self performSelector:@selector(dismiss) withObject:nil afterDelay:delay];
    }
}

- (void)dismiss {
    [UIView animateWithDuration:0.3 animations:^{
        self.container.alpha = 0;
    }];
}

- (UIWindow *)keyWindow {
    for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
        if ([scene isKindOfClass:UIWindowScene.class]) {
            for (UIWindow *window in ((UIWindowScene *)scene).windows) {
                if (window.isKeyWindow) {
                    return window;
                }
            }
        }
    }
    for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
        if ([scene isKindOfClass:UIWindowScene.class]) {
            UIWindow *window = ((UIWindowScene *)scene).windows.firstObject;
            if (window) {
                return window;
            }
        }
    }
    return nil;
}

@end

#else

// macOS：暂不画浮层，状态走日志
@implementation NCHUD
+ (void)showStatus:(NSString *)message state:(NSInteger)state {}
@end

#endif

#endif
