# 使用RxSwift编写iOS的wanandroid客户端

## 前言

尝试学习RxSwift已经是很久之前的事情了，今年通过掘金的活动才基本落地。

之前版本的README写的乱七八糟的，一直想找个机会重新整理一下。

拖拖拉拉的一直推迟到现在，真是不好意思。

## 关于这个项目

这是我第一个Swift的MVVM项目，依旧通过[WanAndroid开放API](https://www.wanandroid.com/)制作。

我已经写了Flutter和uni-app版本，所以Swift版本更看重是对逻辑与RxSwift的理解。

曾经的我更看重在单个UI页面上的编写与实现，现在经常想的是这个有没有现成的轮子可以，更偏向于思路与思考。我不是说UI不需要思考，如果有好用的轮子何乐而不为呢？

**欢迎大家star、pr和一起讨论！！！**

### 注意事项

**感谢大家的厚爱，有很多同学反馈提出了Xcode的编译问题，这里统一回复一下，这个项目目前在持续迭代，虽然可能没有太多的功能变化，目前是使用Xcode14，并且使用了部分Swif5.7的简化语法，`if let与guard let`，所以还请编译有异常的朋友升级Xcode或者自己处理一下。**

### 项目截图

#### 先来一张动图

<div align="center">

![](ScreenShots/example.gif)

</div>

#### 界面截图

| ![](ScreenShots/1.PNG) | ![](ScreenShots/2.PNG) | ![](ScreenShots/3.PNG) | ![](ScreenShots/4.PNG) |
| --- | --- | --- | --- |
| ![](ScreenShots/5.PNG) | ![](ScreenShots/6.PNG) | ![](ScreenShots/7.PNG) | ![](ScreenShots/8.PNG) |  

### 功能说明

* 首页、项目、公众号、体系、我的，五大模块
* 登录注册功能
* 搜索功能：热门搜索、输入搜索
* 文章列表，普通的TableView布局
* Tab切换功能
* 自动轮播图
* MJRefresh的下拉刷新，无感知上拉加载更多
* RxMoya的使用，Moya插件的使用
* RxSwift、RxCocoa的响应式编程，ViewModel的绑定
* 适配iOS 16，Swift语法更新到5.7
* 适配黑暗模式
* 常用扩展封装
* 详细的注释与思考过程

### 引入的第三库

```ruby
# Rx Core
pod 'RxSwift'
pod 'RxCocoa'

# Rx Extensions
pod 'RxDataSources'
pod 'NSObject+Rx'

# 在BaseViewController中有尝试使用,对于添加手势与调用会更加简单
pod 'RxGesture'
# 本质上是将异步操作转换为同步操作,这样使得测试代码更简单,我在Moya转模型中进行了分类编写,可以直接转为可以使用的Result类型
pod 'RxBlocking'

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
pod 'RxSwiftExt' # 更多的是对序列的运算符优化
pod 'RxViewController' # 控制器的生命周期通过rx进行监控
pod 'RxOptional'
pod 'RxTheme' # 可以做主题优化,但是现在基本上适配黑暗模式即可

# Date
pod 'SwiftDate'

# Keychain
pod 'KeychainAccess'

# SFSymbols的安全引用
pod 'SFSafeSymbols', '~> 2.1.3'
```

## 使用RxSwift、Flutter、Vue的一点感受

之前跑去学了Flutter和简单的Vue入门。

说实话Vue的学习成本是最低的，因为它的MVVM框架开箱即用，你不需要做太多的操作，也非常容易理解。

Flutter的学习曲线稍微难一点，但是学会了Provider之后，基本上MVVM的思想也上路了。

反观RxSwift的学习曲线真的是陡峭啊，虽然我理解Oberveral其实就是异步的stream，但是使用起来的时候还是一脸懵逼，偶尔想要使用绑定，还需要自己做Rx的扩展，需要理解大量非原生的API，成本非常的高。

你说为啥不直接上Combine，我只是想说，RxSwift学了，理解Combine还会难么？

SwiftUI+Combine联合起来才能展现威力，不过在苹果这一侧，成熟好用的响应式和状态管理都还没有出世。

而RxSwift系列的一些框架已经在向大前端的实现了，可惜对原生的支持不够好的，学习成本也太高了。

## Flutter版使用GetX重构wanandroid客户端

因为RxSwift的响应式学习，鼓起勇气学习了GetX，重构了Flutter版wanandroid客户端。也希望大家喜欢和支持。

[项目地址](https://github.com/seasonZhu/GetXStudy)

## uni-app版wanandroid客户端

[项目地址](https://github.com/seasonZhu/UniAppPlayAndroid)

## 我的掘金主页

[我的主页](https://juejin.cn/user/4353721778057997)

## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=seasonZhu/RxStudy&type=Date)](https://star-history.com/#seasonZhu/RxStudy&Date)

## SwiftUI + Combine

详细可以看SwiftUIExample这个文件夹的内容,我已经编写了SwiftUI的积分排名页面,包括上下拉,网络请求,异常等处理.
可以说,基本上通过这个页面,CoinRankListPage可以看到交互->数据请求->数据驱动页面等一系列操作.

如果下面这个FuckingSwiftUI都看懂了,基本上SwiftUI布局基本上明白.
我目前是按照Flutter的思路在写SwiftUI的布局,但是其实很多细节还是不明白.

### FuckingSwiftUI

[FuckingSwiftUI](https://github.com/agelessman/FuckingSwiftUI)

### 使用的SwiftUI的组件

下拉与上拉

[Refresh](https://github.com/wxxsw/Refresh)

轮播

[ACarousel](https://github.com/JWAutumn/ACarousel)
