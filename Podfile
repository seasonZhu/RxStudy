# Uncomment the next line to define a global platform for your project
platform :ios, '12.1'
source 'https://github.com/CocoaPods/Specs.git'
#source 'https://mirrors.tuna.tsinghua.edu.cn/git/CocoaPods/Specs.git'

target 'RxStudy' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  
  # Rx Core
  pod 'RxSwift'
  pod 'RxCocoa'
  
  # Rx Extensions
  pod 'RxDataSources'
  pod 'NSObject+Rx'

  # Networking
  pod 'Moya/RxSwift'
  pod 'AlamofireNetworkActivityLogger'

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
  pod 'MBProgressHUD' # 被SVProgressHUD替代了
  
  # Keyboard
  pod 'IQKeyboardManagerSwift'

  # Auto Layout
  pod 'SnapKit'
  
  # 调试
  pod 'LookinServer', :configurations => ['Debug']
  pod 'CocoaDebug', :configurations => ['Debug']
  pod "SwiftPrettyPrint", "~> 1.2.0", :configuration => "Debug"
  
  # 注意,以下是没有使用的库
  
  # Rx Extensions
  pod 'RxSwiftExt' #更多的是对序列的运算符优化
  pod 'RxViewController'
  pod 'RxGesture'
  pod 'RxOptional'
  pod 'RxTheme' # 可以做主题优化,但是现在基本上适配黑暗模式即可
  pod 'RxBlocking'
  
  # Date
  pod 'SwiftDate'
  
  # Keychain
  pod 'KeychainAccess'
  
  # SFSymbols的安全引用
  pod 'SFSafeSymbols', '~> 2.1.3'

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
