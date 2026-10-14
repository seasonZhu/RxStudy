Pod::Spec.new do |s|
  s.name = 'ProgressHUD'
  s.version = '15.0.1'
  s.summary = 'ProgressHUD 本地版本快照，与 Tuist 锁定版本一致'
  s.homepage = 'https://github.com/relatedcode/ProgressHUD'
  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.author = 'relatedcode'
  s.source = { :git => 'https://github.com/relatedcode/ProgressHUD.git', :tag => '15.0.1' }
  s.ios.deployment_target = '17.6'
  s.swift_version = '5.9'
  s.source_files = 'SwiftUI/Sources/**/*.swift'
  s.resources = 'SwiftUI/Sources/PrivacyInfo.xcprivacy'
end
