# iOS UI 设计稿布局落地规则

本文定义项目内 iOS 原生 UI 从设计稿落地到代码时的全局规则，适用于 SnapKit、FlexLayout、PinLayout 三种布局方式。目标是让 375pt、390pt、393pt、430pt 等不同设计基准在真实设备上保持一致的视觉秩序，而不是机械等比缩放所有尺寸。

## 基础原则

iOS 设计稿统一按 pt 理解，不按物理像素 px 直接实现。

```text
px = pt * scale
```

常见换算如下：

| 设计基准 | 2x 画布 | 3x 画布 | 开发理解 |
| --- | ---: | ---: | --- |
| 375pt | 750px | 1125px | 375pt |
| 390pt | 780px | 1170px | 390pt |
| 393pt | 786px | 1179px | 393pt |
| 430pt | 860px | 1290px | 430pt |

不管设计稿来自 2x 还是 3x，开发实现都应落到 pt 尺寸。设计稿宽度只是视觉基准，不应成为页面主容器的固定宽度。

## 总体布局规则

| UI 类型 | 推荐做法 |
| --- | --- |
| 页面容器宽度 | 跟随父视图或屏幕宽度，不写死设计稿宽度 |
| 页面左右间距 | 使用 padding、margin、leading/trailing inset |
| 卡片、输入框、主按钮宽度 | 使用左右约束或父容器剩余空间 |
| 普通控件高度 | 按设计稿固定 pt，例如 44、48、52 |
| 图标、头像、小视觉元素 | 按设计稿固定 pt，例如 16、24、32 |
| 字体大小 | 按设计稿固定 pt，必要时接入 Dynamic Type |
| Banner、封面、车辆图 | 优先使用宽高比 |
| 内容区域高度 | 由内容撑开，或使用滚动容器、安全区约束 |
| 全屏页面高度 | 跟随屏幕和 Safe Area，不按设计稿高度写死 |

横向布局优先靠边距和约束适配，图片类高度优先用比例，控件高度和图标尺寸按设计稿 pt 固定。只有强视觉还原场景才做局部等比缩放。

## 375pt 与 393pt 设计稿处理

项目可能同时收到 375pt 和 393pt 基准的设计稿。开发时不需要把所有尺寸统一换算到同一个基准。

例如：

```text
375pt 设计稿中的 icon = 24 x 24
393pt 设计稿中的 icon = 24 x 24
```

开发实现通常都写为：

```swift
24pt x 24pt
```

不要因为屏幕从 375pt 到 393pt，就把 24pt 自动放大为 25.15pt。图标、字体、按钮高度、常规边距应保持稳定，避免不同页面出现视觉尺度漂移。

可以局部缩放的场景：

| 场景 | 处理方式 |
| --- | --- |
| 普通 icon | 不缩放 |
| 字体 | 不缩放 |
| 按钮高度 | 通常不缩放 |
| 页面左右边距 | 通常不缩放 |
| Banner、封面、车辆图 | 优先按宽高比 |
| 强视觉背景、装饰图形 | 可按设计基准宽度局部缩放 |
| 全屏视觉稿 | 结合比例、裁剪和 Safe Area |

如确实需要缩放，应显式命名基准宽度，并限制使用范围：

```swift
func scaleWidth(_ value: CGFloat, baseWidth: CGFloat = 393.0) -> CGFloat {
    value * UIScreen.main.bounds.width / baseWidth
}
```

该工具只用于大图、特殊视觉装饰、复杂自定义图形，不作为所有尺寸的默认处理方式。

## 框架选择规则

项目 iOS 原生页面应遵循以下优先级：

1. 如果所在模块已经集成并使用 FlexLayout 与 PinLayout，优先沿用既有体系。
2. 复杂内容块、卡片嵌套、动态信息流优先使用 FlexLayout。
3. 高性能列表 cell、自定义组件、高频刷新区域优先使用 PinLayout。
4. 普通 UIKit 页面、表单、详情页、页面骨架优先使用 SnapKit。
5. 如果没有 FlexLayout、PinLayout、SnapKit，再使用原生 Auto Layout。

同一个组件内部尽量只使用一种布局体系。可以用 SnapKit 搭页面骨架，在某个局部内容块内部使用 FlexLayout 或 PinLayout，但不要在同一层级混杂多套布局规则。

## SnapKit 规则

SnapKit 的核心是约束关系。适合页面骨架、表单、设置页、详情页、普通业务页。

推荐写法：

```swift
containerView.snp.makeConstraints { make in
    make.top.equalTo(view.safeAreaLayoutGuide)
    make.leading.trailing.equalToSuperview()
    make.bottom.equalToSuperview()
}

cardView.snp.makeConstraints { make in
    make.top.equalToSuperview().offset(16)
    make.leading.trailing.equalToSuperview().inset(16)
}

iconView.snp.makeConstraints { make in
    make.size.equalTo(CGSize(width: 24, height: 24))
    make.leading.equalToSuperview().offset(16)
    make.centerY.equalToSuperview()
}

titleLabel.snp.makeConstraints { make in
    make.leading.equalTo(iconView.snp.trailing).offset(8)
    make.trailing.equalToSuperview().inset(16)
    make.centerY.equalToSuperview()
}

bannerView.snp.makeConstraints { make in
    make.leading.trailing.equalToSuperview().inset(16)
    make.height.equalTo(bannerView.snp.width).multipliedBy(180.0 / 361.0)
}
```

SnapKit 中应避免：

```swift
make.width.equalTo(393)
```

除非这是固定宽度弹窗、浮层或特殊组件。主页面、列表项、卡片、按钮、输入框不应写死屏幕宽度。

SnapKit 标注转换：

| 设计稿标注 | SnapKit 实现 |
| --- | --- |
| 页面左右 16 | `make.leading.trailing.equalToSuperview().inset(16)` |
| icon 24 x 24 | `make.size.equalTo(24)` |
| 按钮高 48 | `make.height.equalTo(48)` |
| Banner 361 x 180 | `height = width * 180 / 361` |
| 底部按钮距底部 | 约束到 `safeAreaLayoutGuide` |
| 文本可换行 | 设置 numberOfLines，并约束 trailing |

## FlexLayout 规则

FlexLayout 的核心是流式排版，适合复杂横纵嵌套、动态内容、信息卡片、前端式结构页面。

推荐思路：

```swift
rootFlex.flex
    .direction(.column)
    .paddingHorizontal(16)
    .paddingTop(12)

cardView.flex
    .direction(.column)
    .padding(16)
    .marginBottom(12)

rowView.flex
    .direction(.row)
    .alignItems(.center)

iconView.flex
    .width(24)
    .height(24)
    .marginRight(8)

titleLabel.flex
    .grow(1)

bannerView.flex
    .width(100%)
    .aspectRatio(361.0 / 180.0)
```

FlexLayout 标注转换：

| 设计稿标注 | FlexLayout 实现 |
| --- | --- |
| 页面左右边距 | 外层 `paddingHorizontal` |
| 卡片内部边距 | 卡片 `padding` |
| 元素间距 | 子元素 `marginRight`、`marginBottom` |
| 横向标题加 icon | `direction(.row)` + `alignItems(.center)` |
| 文本占剩余宽度 | `grow(1)` |
| 图片比例 | `aspectRatio` |

FlexLayout 注意事项：

- 文本变化后需要 `markDirty()` 并触发布局。
- 通常在 `layoutSubviews()` 中调用 `flex.layout()`。
- Safe Area 仍应由外层容器处理。
- 不要在同一个 Flex 子树内部额外叠加大量 Auto Layout 约束。

## PinLayout 规则

PinLayout 的核心是 frame 计算和相对定位。适合高性能列表 cell、自定义组件、高频刷新视图。

推荐写法：

```swift
iconView.pin
    .left(16)
    .vCenter()
    .width(24)
    .height(24)

titleLabel.pin
    .after(of: iconView)
    .marginLeft(8)
    .right(16)
    .sizeToFit(.width)
```

Banner 示例：

```swift
let bannerWidth = contentView.bounds.width - 32
let bannerHeight = bannerWidth * 180.0 / 361.0

bannerView.pin
    .top(16)
    .horizontally(16)
    .height(bannerHeight)
```

PinLayout 标注转换：

| 设计稿标注 | PinLayout 实现 |
| --- | --- |
| 页面左右 16 | `left(16).right(16)` 或 `horizontally(16)` |
| icon 固定尺寸 | `width(24).height(24)` |
| 横向相邻元素 | `after(of:)`、`before(of:)` |
| 纵向相邻元素 | `below(of:)` |
| 文本高度 | 先确定宽度，再 `sizeToFit(.width)` |
| Cell 高度 | 根据最后一个元素 bottom 反推 |

PinLayout 注意事项：

- 布局通常写在 `layoutSubviews()`。
- 父视图 bounds 变化后必须重新布局。
- 动态文本先确定宽度，再计算高度。
- 动态 cell 高度应集中计算，不要把高度逻辑散落在多个地方。

## 统一尺寸常量

常用间距、尺寸、圆角、设计基准应集中定义，避免散写 magic number。

```swift
enum AppSpacing {
    static let pageHorizontal: CGFloat = 16
    static let cardPadding: CGFloat = 16
    static let itemSpacing: CGFloat = 8
    static let sectionSpacing: CGFloat = 12
}

enum AppSize {
    static let iconSmall: CGFloat = 16
    static let iconNormal: CGFloat = 24
    static let buttonHeight: CGFloat = 48
    static let cornerRadius: CGFloat = 8
}

enum AppDesign {
    static let baseWidth: CGFloat = 393
}
```

`AppDesign.baseWidth` 只用于少量视觉缩放，不用于所有控件的默认缩放。

## 适配检查

实现 UI 后至少检查以下逻辑宽度：

| 设备类型 | 逻辑宽度 |
| --- | ---: |
| 小屏 | 375pt |
| 常规屏 | 390pt / 393pt |
| 大屏 | 428pt / 430pt |

检查重点：

- 左右边距是否稳定。
- 文本是否截断或重叠。
- 按钮文字是否溢出。
- 图片比例是否正确。
- 底部按钮是否避开 Safe Area。
- 小屏内容是否可以滚动。
- 大屏内容是否过度拉伸。
- 图标、字体、按钮高度是否被错误缩放。

## 最终约定

1. 设计稿无论 2x 或 3x，开发统一按 pt 落地。
2. 页面和卡片宽度不写死，使用左右边距或父容器约束。
3. icon、头像、字体、按钮高度按设计稿 pt 固定。
4. 图片、Banner、车辆图等视觉区域优先按宽高比适配。
5. 页面高度不按设计稿写死，使用 Safe Area、内容撑开和滚动容器。
6. 只有强视觉还原场景允许基于 375pt 或 393pt 做局部缩放。
7. SnapKit 负责约束关系，FlexLayout 负责流式内容，PinLayout 负责高性能 frame 布局。
8. 同一组件内部尽量只使用一种布局体系。
9. 所有常用间距、尺寸、圆角、设计基准宽度统一放入设计常量。
10. 每个 iOS 原生页面至少验证 375pt、393pt、430pt 三类宽度。
