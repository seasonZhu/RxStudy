//
//  FunnyButton.Window.swift
//  FunnyButton
//
//  Created by aa on 2022/9/17.
//
//  FunnyButton所在窗口

internal extension FunnyButton {
    class FunWindow: UIWindow {
        static let shared = FunWindow()
        
        init() {
            super.init(frame: UIScreen.main.bounds)
            isHidden = true
            
            if #available(iOS 13, *) {
                for scene in UIApplication.shared.connectedScenes {
                    guard let wScene = scene as? UIWindowScene else { continue }
                    windowScene = wScene
                    break
                }
            }
            
            windowLevel = .statusBar
            rootViewController = RootVC()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        /// 📢 对于`UIWindow`的特殊处理：
        public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
            guard !isHidden, subviews.count > 0 else { return nil }
            for subview in subviews.reversed() where !subview.isHidden && subview.alpha > 0.01 && subview.frame.contains(point) {
                /// 由于`UIWindow`会存在系统添加的一些私有类，例如`UITransitionView`，占全屏区域，是`rootVC.presentedVC.view`的父视图。
                /// 但在iPad端，当`rootVC.presentedVC`为空时，`UITransitionView`则会放入`UIDropShadowView`，
                /// `UIDropShadowView`是私有类，也是占全屏并且能响应手势（应该是专门处理拖拽事件），阻拦了手势的穿透，
                /// 因此需要对此进行【过滤】判定。
                if rootViewController?.presentedViewController == nil, let cls = NSClassFromString("UITransitionView"), subview.isKind(of: cls) {
                    continue
                }
                
                let subPoint = convert(point, to: subview)
                guard let rspView = subview.hitTest(subPoint, with: event) else { continue }
                return rspView
            }
            return nil
        }
        
        override var canBecomeKey: Bool { false }
        
        override var isKeyWindow: Bool { false }
        
        func show() { isHidden = false }
        
        func hide() { isHidden = true }
    }
}

private extension FunnyButton.FunWindow {
    class RootVC: UIViewController {
        override func viewDidLoad() {
            super.viewDidLoad()
            view.isUserInteractionEnabled = false
        }

        override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
            DispatchQueue.main.async { self.updateFunnyLayout() }
        }
        
        override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
            FunnyButton.orientationMask ?? super.supportedInterfaceOrientations
        }
        
        override var shouldAutorotate: Bool { true }
    }
}

