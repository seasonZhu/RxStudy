# 定义全局变量
IOS_DEPLOYMENT_TARGET = '17.6'

# Uncomment the next line to define a global platform for your project
platform :ios, IOS_DEPLOYMENT_TARGET
#source 'https://github.com/CocoaPods/Specs.git'
#source 'https://mirrors.tuna.tsinghua.edu.cn/git/CocoaPods/Specs.git'

flutter_application_path = 'flutter_module'
load File.join(flutter_application_path, '.ios', 'Flutter', 'podhelper.rb')

target 'RxStudy' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  
  # Rx Core
  pod 'RxSwift'
  pod 'RxCocoa'
  
  # Rx Extensions
  pod 'RxDataSources'
  pod 'NSObject+Rx'
  
  # 在BaseViewController中有尝试使用,对于添加手势与调用会更加简单
  pod 'RxGesture'
  
  # 本质上是将异步操作转换为同步操作,这样使得测试代码更简单,
  # 我在Moya转模型中进行了分类编写,可以直接转为可以使用的Result类型,同时BlockingObservable的注释也说了,它用于测试与演示,并不适合用于App的生产环境,当你在程序逻辑中使用BlockingObservable,也许是该反省自己写的代码逻辑的时候了
  pod 'RxBlocking'
  
  # 可以做主题优化,但是现在基本上适配黑暗模式即可,尝试做了全局主题,但是我想的太简单了
  pod 'RxTheme'

  # Networking
  pod 'Moya/RxSwift'
  # AlamofireNetworkActivityLogger的版本很久都没有升级,导致其绑定Alamofire无法升级,直接移除拖入,保证Alamofire和Moya可以向上升级,然后直接改写为Moya插件,因为Alamofire的升级,改写的Moya插件也无法正常工作了
  #pod 'AlamofireNetworkActivityLogger'

  # Image
  pod 'Kingfisher'
  
  # R函数
  pod 'R.swift'

  # UI
  pod 'DZNEmptyDataSet'
  pod 'AcknowList'
  pod 'MJRefresh'
  pod 'FSPagerView'
  pod 'JXSegmentedView'
  pod 'MarqueeLabel'
  pod 'SVProgressHUD'
  
  # SFSymbols的安全引用
  pod 'SFSafeSymbols'
  
  # Keyboard,弹不出来的原因是8.0.0之后拆分为不同的模块,需要分别进行配置
  pod 'IQKeyboardManagerSwift', :git => 'https://github.com/hackiftekhar/IQKeyboardManager.git', :tag => '8.0.2'

  # Auto Layout
  pod 'SnapKit'
  
  # Yoga Layout
  pod 'FlexLayout'
  pod 'PinLayout'
  
  # Combine 学习
  pod 'Moya/Combine'
  pod 'CombineExt'
  pod 'CombineCocoa'
  
  # 微软 Bug&Crash
  pod 'KSCrash'
  
  # 调试
  pod 'LookinServer', :configurations => ['Debug']
  pod 'CocoaDebug', :configurations => ['Debug']
  pod 'FunnyButton', :configurations => ['Debug']
  
  # 在Xcode16.2下面会报错,暂时不使用
  #pod 'MLeaksFinder', :configurations => ['Debug']
  pod 'LifetimeTracker', :configurations => ['Debug']
  
  # 日志打印与跟踪
  pod 'CocoaLumberjack/Swift'
  
  # 用于日志压缩为zip
  pod 'SSZipArchive'
  
  # 缓存
  #pod 'Cache'
  #pod 'YYCache'
  
  # 考虑使用货拉拉的TheRouter
  pod 'TheRouter'
  
  ### 注意,以下是没有使用的库
  
  # Rx Extensions
  
  # 对序列的操作符的扩充,让序列从一种类型转换到另一种类型变得更加快捷 https://github.com/RxSwiftCommunity/RxSwiftExt
  pod 'RxSwiftExt'
  pod 'RxViewController'
  pod 'RxOptional'
  
  # Date
  pod 'SwiftDate'
  
  # Keychain
  pod 'KeychainAccess'
  
  # SwiftLint
  #pod 'SwiftLint', :configuration => 'Debug'
  
  # web缓存+离线缓存
  pod 'JWNetAutoCache'
  
  # 被SVProgressHUD替代了,目前没有使用
  pod 'MBProgressHUD'
  
  ### 跨端模块
  
  # 添加flutter模块
  #install_all_flutter_pods(flutter_application_path)
  
  # 添加UniApp模块
  ## 判断需要引用哪些模块请参考文档:https://nativesupport.dcloud.net.cn/AppDocs/usemodule/iOSModuleConfig/common.html#%E5%A6%82%E4%BD%95%E9%85%8D%E7%BD%AE%E6%A8%A1%E5%9D%97-%E4%B8%89%E6%96%B9sdk
  ## 根据功能对照表添加，建议一次不要Pod太多模块容易超时
  ## 我的HBuilder是4.36,编译的wgt也是这个版本的,最好SDK版本与HBuilder编译版本一致,减少告警弹窗
  pod 'unimp', '4.36', :subspecs => [
        'Core',               ##核心库(必需)
#        'Log',                ##
#        'Accelerometer',      ##加速度传感器
#        'Contacts',           ##通讯录
#        'Audio',              ##音频
#        'Camera&Gallery',     ##相机&相册
        'File',               ##文件
#        'Video',              ##视频播放
#        'LivePusher',         ##直播推流
#        'NativeJS',           ##JS Reflection call Native
#        'Orientation',        ##设备方向
#        'Message',            ##邮件消息
#        'Zip',                ##压缩
#        'Proximity',          ##距离传感器
#        'Sqlite',             ##数据库
#        'XMLHttpRequest',     ##网络请求
#        'Fingerprint',        ##指纹识别
#        'FaceId',             ##人脸识别
#        'IBeacon',            ##底功耗蓝牙
#        'BlueTooth',          ##蓝牙
#        'Speech-Baidu',       ##语音识别-百度
#        'Statistic-Umeng',    ##友盟统计
#        ##定位模块(百度高德不能同时引用)
#        'Geolocation',        ##系统定位
#        'Geolocation-Gaode',  ##高德定位
#        'Geolocation-Baidu',  ##百度定位
#        ##地图(二选一)
#        'Map-Gaode',          ##高德地图
#        'Map-Baidu',          ##百度地图
#        ##支付
#        'Payment-IAP',        ##苹果内购
#        'Payment-AliPay',     ##支付宝支付
#        'Payment-Wechat',     ##微信支付-同时使用微信分享或登录,必需使用包含支付的依赖库
#        'Payment-Paypal',     ##Paypal支付 iOS13+
#        'Payment-Stripe',     ##stripe支付 iOS13+ 依赖库较大如果超时建议使用代理
#        ##分享
#        'Share-Wechat',       ##微信分享-包含支付
#        'Share-WechatNopay',  ##微信分享-不包含支付
#        'Share-QQ',           ##QQ分享
#        'Share-Sina',         ##新浪微博分享
#        ##登录
#        'Oauth-Apple',        ##苹果登录
#        'Oauth-QQ',           ##QQ登录
#        'Oauth-Wechat',       ##微信登录-包含支付
#        'Oauth-WechatNopay',  ##微信登录-不包含支付
#        'Oauth-Sina',         ##新浪微博登录
#        'Oauth-Google',       ##Google登录
#        'Oauth-Facebook',     ##Facebook登录 iOS12+
  ]


end

=begin
pre_install do |installer|
  require 'typhoeus'
  Typhoeus::Config.user_agent = 'CocoaPods'
  # ....
  
end
=end

# 如果你是M1系列芯片,请添加下面的脚本, 去掉=begin和=end,便于在模拟器上运行
=begin
post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            # Needed for building for simulator on M1 Macs
            config.build_settings['ONLY_ACTIVE_ARCH'] = 'NO'
        end
    end
end
=end


post_install do |installer|
  # 1) Ensure pods have a minimum deployment target of iOS 17.6 when they declare a lower one
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      if config.build_settings['IPHONEOS_DEPLOYMENT_TARGET']
        begin
          current = Gem::Version.new(config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'])
          if current < Gem::Version.new(IOS_DEPLOYMENT_TARGET)
            config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = IOS_DEPLOYMENT_TARGET
          end
        rescue
          # if parsing fails, be conservative and set to 17.6
          config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = IOS_DEPLOYMENT_TARGET
        end
      else
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = IOS_DEPLOYMENT_TARGET
      end

      # 2) Disable Bitcode for pod targets to avoid bitcode-related override issues
      config.build_settings['ENABLE_BITCODE'] = 'NO'
    end
  end

  # 3) Prevent "Target overrides the 'ENABLE_BITCODE' build setting" warnings by making
  # app/user project targets use $(inherited) for ENABLE_BITCODE (so CocoaPods xcconfigs are authoritative)
  installer.aggregate_targets.each do |aggregate|
    project = aggregate.user_project
    project.targets.each do |user_target|
      user_target.build_configurations.each do |config|
        config.build_settings['ENABLE_BITCODE'] = '$(inherited)'
      end
    end
  end
  
  # 通过打印RxSwift.Resources.total表示当前的RxSwift中资源使用情况
  # https://juejin.cn/post/7088692280852217887
  # https://www.jianshu.com/p/671a68870bdf
  # Preserve existing behavior for RxSwift tracing flag
  installer.pods_project.targets.each do |target|
    if target.name == 'RxSwift'
      target.build_configurations.each do |config|
        if config.name == 'Debug'
          config.build_settings['OTHER_SWIFT_FLAGS'] ||= ['-D', 'TRACE_RESOURCES']
        end
      end
    end
  end

  flutter_post_install(installer) if defined?(flutter_post_install)
end

plugin 'cocoapods-keys', {
  :project => "RxStudy",
  :keys => [
    "TEST_KEY"
  ]
}
