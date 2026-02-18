# FunnyButton

在平时开发，运行期间有时候想中途看一下某个视图或变量的信息，虽说打断点是可以查看，但有时候断点调试有时候会卡住好一会才能看到（尤其是大项目经常卡很久），极度影响效率。

基于这种情况，`FunnyButton`就是为了能够便捷调试的全局按钮，添加好调试事件，就能随时点击查看某个视图或变量的信息，又可以直接调试某些函数。

    Feature：
        ✅ 位于Window层级，不会被app内的界面覆盖；
        ✅ 自适应安全区域，自动靠边，适配横竖屏；
        ✅ 可执行单个/多个调试事件；
        ✅ 兼容`iPhone`&`iPad`；
        ✅ 兼容Objective-C环境调试；
        ✅ API简单易用。

`SwiftUI`版本：[FunnyButton_SwiftUI](https://github.com/Rogue24/FunnyButton_SwiftUI)

## Effect
- 单个调试事件

![single_action](https://github.com/Rogue24/JPCover/raw/master/FunnyButton_SwiftUI/single_action.gif)

- 多个调试事件

![multiple_actions](https://github.com/Rogue24/JPCover/raw/master/FunnyButton_SwiftUI/multiple_actions.gif)

## Basic use

为了兼容OC，基于`NSObject`的扩展提供给所有基类设置调试事件的接口，以`UIViewController`为例：

- Swift
```swift
// 建议初始化好页面时设置
override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    // 设置调试事件
    replaceFunnyAction {
        // 注意内存泄漏：闭包内部用到`self`记得使用`[weak self]`
        print("点我干森莫")
    }
}

// 建议页面即将消失时移除这些事件
override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    // 移除调试事件
    removeFunnyActions()
}
```

- Objective-C
```objc
// 建议初始化好页面时设置
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // 设置调试事件
    [self replaceFunnyActionWithWork:^{
        // 注意内存泄漏：闭包内部用到`self`记得使用`__weak`
        NSLog(@"点我干森莫");
    }];
}

// 建议页面即将消失时移除这些事件
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // 移除调试事件
    [self removeFunnyActions];
}
```

## API

`FunnyButton.API.swift` - 公开可使用接口。

- replace action - 替换、覆盖全部事件
```swift
/// 替换单个`Action`
@objc func replaceFunnyAction(work: @escaping () -> ()) { ... }

/// 替换多个`Action`
@objc func replaceFunnyActions(_ actions: [FunnyAction]) { ... }
```

- add action - 在已有的事件上添加新的事件
```swift
/// 添加单个`Action`
@objc func addFunnyAction(name: String? = nil, work: @escaping () -> ()) { ... }

/// 添加多个`Action`
@objc func addFunnyActions(_ actions: [FunnyAction]) { ... }
```

- remove action - 删除目标/全部事件
```swift
/// 带条件移除目标`Action`（`decide`返回`true`则删除）
@objc func removeFunnyActions(where decide: (FunnyAction) -> Bool) { ... }

/// 移除所有`Action`
@objc func removeFunnyActions() { ... }
```
    
- update layout - 刷新布局
```swift
/// 刷新`FunnyButton`布局
@objc func updateFunnyLayout() { ... }
```

## Custom button UI 

`FunnyButton.swift` - 可改动的UI属性均为静态属性，且有默认实现，如需改动建议启动App时配置。

```swift
public class FunnyButton: UIButton {
    ......
    
    /// 普通状态
    static var normalEmoji = "😛"
    
    /// 点击状态
    static var touchingEmoji = "😝"
    
    /// 毛玻璃样式（nil为无毛玻璃）
    static var effect: UIVisualEffect? = {
        if #available(iOS 13, *) {
            return UIBlurEffect(style: .systemThinMaterial)
        }
        return UIBlurEffect(style: .prominent)
    }()
    
    /// 背景色
    static var bgColor: UIColor? = UIColor(red: 200.0 / 255.0, green: 100.0 / 255.0, blue: 100.0 / 255.0, alpha: 0.2)
    
    /// 初始点（想`靠右/靠下`的话，`x/y`的值就设置大一点，最后会靠在安全区域的边上）
    static var startPoint: CGPoint = CGPoint(x: 600, y: 100)
    
    /// 安全区域的边距
    static var safeMargin: CGFloat = 12
    
    ......
}

// Initialization Example:
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    ......
    
    FunnyButton.normalEmoji = "🦖"
    FunnyButton.touchingEmoji = "🐲"

    return true
}
```

## Installation

FunnyButton is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'FunnyButton', :configurations => ['Debug']
```

## Author

Rogue24, zhoujianping24@hotmail.com

## License

FunnyButton is available under the MIT license. See the LICENSE file for more info.
