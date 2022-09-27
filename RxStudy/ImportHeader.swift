//
//  Header.swift
//  RxStudy
//
//  Created by dy on 2022/1/13.
//  Copyright © 2022 season. All rights reserved.
//

/// 尝试把所以的第三方库通过一个.swift文件引用后,希望其他文件就可以不用引用了
/// 但是这个是无法实现的
/// 另外,在新版的Xcode中,有些OC库,即时不桥接也可以直接在Swift中import,下面的import MJRefresh就是例子
/// 通过观察,不需要使用桥接,是Pods/Products/MJRefresh.framework/Modules/module.modulemap的配置
/// 但是,需要注意的是,有些库还是必须要桥接的,比如支付宝的SDK\微信的SDK等,所以并不是完全可以去掉Bridging文件的,已在其他工程中验证
/// Swift：巧用module.modulemap，告别Bridging-Header.h,https://juejin.cn/post/7139724115157450765

import AcknowList
import Alamofire
import AlamofireNetworkActivityLogger
import DZNEmptyDataSet
import FSPagerView
import IQKeyboardManagerSwift
import JXSegmentedView
import KeychainAccess
import Kingfisher
import MarqueeLabel
import MBProgressHUD
import MJRefresh
import Moya
import NSObject_Rx
import RxCocoa
import RxSwift
import SFSafeSymbols
import SnapKit
import SVProgressHUD
import SwiftDate
import SwiftPrettyPrint
