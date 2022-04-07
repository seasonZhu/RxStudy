# Uncomment the next line to define a global platform for your project
 platform :ios, '12.1'

target 'RxStudy' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  
  # Rx Core
  pod 'RxSwift'
  pod 'RxCocoa'

  # Networking
  pod 'Moya/RxSwift'
 
  # AlamofireNetworkActivityLogger集成
  pod 'AlamofireNetworkActivityLogger'

  # Rx Extensions
  pod 'RxDataSources'
  pod 'RxSwiftExt' #暂时没有使用,更多的是对序列的运算符优化
  pod 'RxViewController' # 暂时没有使用
  pod 'RxGesture' # 暂时没有使用
  pod 'RxOptional' # 暂时没有使用
  pod 'RxTheme' # 暂时没有使用,可以做主题优化,但是现在基本上适配黑暗模式即可
  pod 'RxBlocking' # 暂时没有使用
  pod 'NSObject+Rx'


  # Image
  pod 'Kingfisher'
  # Date
  pod 'SwiftDate' # 暂时没有使用

  # Tools
  pod 'R.swift'

  # Keychain
  pod 'KeychainAccess' # 暂时没有使用

  # UI'
  pod 'DZNEmptyDataSet'
  pod 'AcknowList'
  pod 'MBProgressHUD' # 被SVProgressHUD替代了
  pod 'MJRefresh'
  pod 'FSPagerView'
  pod 'JXSegmentedView'
  pod 'MarqueeLabel'
  pod 'SVProgressHUD'
  
  # Keyboard
  pod 'IQKeyboardManagerSwift'

  # Auto Layout
  pod 'SnapKit'

  # 打印日志
  pod "SwiftPrettyPrint", "~> 1.2.0", :configuration => "Debug" # enabled on `Debug` build only
    
  # SFSymbols的安全引用
  pod 'SFSafeSymbols', '~> 2.1.3' #暂时没有使用

end

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
