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
        
        override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
            guard !isHidden, subviews.count > 0 else { return nil }
            for subview in subviews.reversed() where !subview.isHidden && subview.alpha > 0.01 && subview.frame.contains(point) {
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

