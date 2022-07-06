# Uncomment the next line to define a global platform for your project
platform :ios, '13.0'
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
  pod 'RxGesture'

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
  
  # Combine 学习
  pod 'Moya/Combine'
  pod 'CombineExt'
  pod 'CombineCocoa'
  
  # 调试
  pod 'LookinServer', :configurations => ['Debug']
  pod 'CocoaDebug', :configurations => ['Debug']
  pod "SwiftPrettyPrint", "~> 1.2.0", :configuration => "Debug"
  
  # 注意,以下是没有使用的库
  
  # Rx Extensions
  
  # 对序列的操作符的扩充,让序列从一种类型转换到另一种类型变得更加快捷 https://github.com/RxSwiftCommunity/RxSwiftExt
  pod 'RxSwiftExt'
  pod 'RxViewController'
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

# 通过打印RxSwift.Resources.total表示当前的RxSwift中资源使用情况 https://juejin.cn/post/7088692280852217887
post_install do |installer|

  installer.pods_project.targets.each do |target|

    if target.name == 'RxSwift'

      target.build_configurations.each do |config|

        if config.name == 'Debug'

          config.build_settings['OTHER_SWIFT_FLAGS'] ||= ['-D', 'TRACE_RESOURCES']

        end

      end

    end

  end

end
