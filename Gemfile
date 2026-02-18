source "https://rubygems.org"

# Cocoapods-sled 是一个简单易用的 Cocoapods 插件，通过缓存和复用Xcode编译结果完成二进制化
# https://github.com/git179979506/cocoapods-sled
gem 'cocoapods-sled'


gem "fastlane"
plugins_path = File.join(File.dirname(__FILE__), 'fastlane', 'Pluginfile')
eval_gemfile(plugins_path) if File.exist?(plugins_path)
