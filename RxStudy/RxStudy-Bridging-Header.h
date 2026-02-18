//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

/// 需要注意的是,有些库还是必须要桥接的,比如支付宝的SDK\微信的SDK等,所以并不是完全可以去掉Bridging文件的
#import "CrashController.h"
#import "NSURLProtocol+WKWebVIew.h"

/// 设置更换图标相关的hook
#import "UIApplication+SetAppIcon.h"
#import "LSApplicationProxy.h"
#import "LSBundleProxy.h"

/// UniApp 库已移除（Flutter/UniApp 模块已移除）
// #import "DCUniMP.h"
// #import "WeexSDK.h"

/// ========== 第三方库（不支持SPM）桥接头文件 ==========
/// 仅 Objective-C 库需要在此导入
#import "TheRouterableProxy.h"
#import "TheRouterDynamicParamsMapping.h"
#import "MBProgressHUD.h"
#import "SVProgressHUD.h"
#import "MJRefresh.h"
#import "UIScrollView+EmptyDataSet.h"
#import "UIScrollView+MJRefresh.h"
/// FSPagerView、JXSegmentedView、NSObject+Rx、TheRouter 是 Swift 库，直接编译到主目标中，不需要在此导入

#define guard(wish) if (wish);
