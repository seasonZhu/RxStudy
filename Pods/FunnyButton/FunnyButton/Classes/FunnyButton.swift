//
//  FunnyButton.swift
//  FunnyButton
//
//  Created by aa on 2022/9/17.
//

public class FunnyButton: UIButton {
    public static let shared = FunnyButton()
    
    /// 普通状态
    public static var normalEmoji = "😛"
    
    /// 点击状态
    public static var touchingEmoji = "😝"
    
    /// 毛玻璃样式（nil为无毛玻璃）
    public static var effect: UIVisualEffect? = {
        if #available(iOS 13, *) {
            return UIBlurEffect(style: .systemThinMaterial)
        }
        return UIBlurEffect(style: .prominent)
    }()
    
    /// 背景色
    public static var bgColor: UIColor? = UIColor(red: 200.0 / 255.0, green: 100.0 / 255.0, blue: 100.0 / 255.0, alpha: 0.2)
    
    /// 初始点（想`靠右/靠下`的话，`x/y`的值就设置大一点，最后会靠在安全区域的边上）
    public static var startPoint: CGPoint = CGPoint(x: 600, y: 100)
    
    /// 安全区域的边距
    public static var safeMargin: CGFloat = 12
    
    /// 自定义可支持的屏幕方向（nil为系统默认）
    public static var orientationMask: UIInterfaceOrientationMask? = nil
    
    
    /// 点击`Action`（单个直接执行，多个则弹出系统Sheet选择执行）
    public var actions: [FunnyAction]?
    
    
    private var _safeFrame: CGRect = .zero
    private var _isPanning: Bool = false
    private var _isTouching: Bool = false
    private(set) var isTouching: Bool {
        set {
            guard _isTouching != newValue else { return }
            _isTouching = newValue
            _touchAnimation()
        }
        get { _isTouching }
    }
    
    private let bgView = UIVisualEffectView(effect: FunnyButton.effect)
    private let emojiLabel = UILabel()
    private lazy var impactFeedbacker = UIImpactFeedbackGenerator(style: .light)
    
    
    init() {
        let scale = min(min(UIScreen.main.bounds.width, UIScreen.main.bounds.height) / 375.0, 1.7)
        let wh = 55 * scale
        super.init(frame: CGRect(origin: FunnyButton.startPoint, size: CGSize(width: wh, height: wh)))
        _setupUI()
        _setupAction()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override var isHighlighted: Bool {
        set {}
        get { super.isHighlighted }
    }
}

private extension FunnyButton {
    func _setupUI() {
        bgView.frame = bounds
        bgView.layer.cornerRadius = bounds.height * 0.5
        bgView.layer.borderWidth = 0
        bgView.layer.masksToBounds = true
        bgView.backgroundColor = Self.bgColor
        bgView.isUserInteractionEnabled = false
        addSubview(bgView)
        
        emojiLabel.text = Self.normalEmoji
        emojiLabel.font = .systemFont(ofSize: bounds.height * 0.9)
        emojiLabel.textAlignment = .center
        emojiLabel.frame = bounds
        addSubview(emojiLabel)
        emojiLabel.transform = CGAffineTransform(scaleX: 0.65, y: 0.65)
    }
    
    func _setupAction() {
        addTarget(self, action: #selector(_beginTouch), for: .touchDown)
        addTarget(self, action: #selector(_beginTouch), for: .touchDragInside)
        addTarget(self, action: #selector(_endTouch), for: .touchDragOutside)
        addTarget(self, action: #selector(_endTouch), for: .touchUpOutside)
        addTarget(self, action: #selector(_endTouch), for: .touchCancel)
        addTarget(self, action: #selector(_touchUpInside), for: .touchUpInside)
        addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(_panMe(_:))))
    }
}

private extension FunnyButton {
    func _markSafeFrame(_ frame: CGRect, isMoving: Bool) -> CGRect {
        var f = frame
        
        let interFrame = isMoving ? _safeFrame : _safeFrame.insetBy(dx: Self.safeMargin, dy: Self.safeMargin)
        
        if f.origin.x < interFrame.origin.x {
            f.origin.x = interFrame.origin.x
        } else if f.maxX > interFrame.maxX {
            f.origin.x = interFrame.maxX - f.width
        }
        
        if f.origin.y < interFrame.origin.y {
            f.origin.y = interFrame.origin.y
        } else if f.maxY > interFrame.maxY {
            f.origin.y = interFrame.maxY - f.height
        }
        
        return f
    }
    
    func _touchAnimation() {
        let bgViewTransform: CGAffineTransform
        let emojiLabelTransform: CGAffineTransform
        
        if _isTouching {
            emojiLabel.text = Self.touchingEmoji
            bgViewTransform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            emojiLabelTransform = CGAffineTransform(scaleX: 1.15, y: 1.15)
            
            impactFeedbacker.prepare()
            impactFeedbacker.impactOccurred()
        } else {
            emojiLabel.text = Self.normalEmoji
            bgViewTransform = CGAffineTransform(scaleX: 1, y: 1)
            emojiLabelTransform = CGAffineTransform(scaleX: 0.65, y: 0.65)
        }
        
        UIView.animate(withDuration: 0.8, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 1, options: [], animations: {
            self.bgView.transform = bgViewTransform
            self.emojiLabel.transform = emojiLabelTransform
        }, completion: nil)
    }
    
    func _executeActions() {
        guard let actions = self.actions, actions.count > 0 else { return }
        
        if actions.count == 1 {
            actions[0].work()
            return
        }
        
        guard let rootVC = window?.rootViewController else { return }
        
        let alertCtr = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        for i in 0 ..< actions.count {
            let action = actions[i]
            alertCtr.addAction(
                UIAlertAction(title: action.name ?? "work \(i + 1)", style: .default) { _ in action.work() }
            )
        }
        alertCtr.addAction(UIAlertAction(title: "取消", style: .cancel))
        
        if let popover = alertCtr.popoverPresentationController {
            let frame = convert(bounds, to: rootVC.view)
            
            var origin = CGPoint(x: 0, y: frame.midY)
            var arrowDirections: UIPopoverArrowDirection = .any
            
            if frame.midX < rootVC.view.frame.midX {
                origin.x = frame.maxX + 12
                arrowDirections = .left
            } else {
                origin.x = frame.origin.x - 12
                arrowDirections = .right
            }
            
            popover.sourceView = rootVC.view
            popover.sourceRect = CGRect(origin: origin, size: .zero)
            popover.permittedArrowDirections = arrowDirections
        }
        
        rootVC.present(alertCtr, animated: true)
    }
}

private extension FunnyButton {
    @objc func _beginTouch() {
        isTouching = true
    }
    
    @objc func _endTouch() {
        guard !_isPanning else { return }
        isTouching = false
    }
    
    @objc func _touchUpInside() {
        isTouching = false
        _executeActions()
    }
    
    @objc func _panMe(_ panGR: UIPanGestureRecognizer) {
        guard let superView = self.superview else { return }
        
        let translation = panGR.translation(in: superView)
        panGR.setTranslation(.zero, in: superView)
        
        switch panGR.state {
        case .ended, .cancelled, .failed:
            moveToBorder(animated: true)
        default:
            _isPanning = true
            var frame = self.frame
            frame.origin.x += translation.x
            frame.origin.y += translation.y
            self.frame = _markSafeFrame(frame, isMoving: true)
        }
    }
}

internal extension FunnyButton {
    func updateSafeFrame() {
        guard let window = self.window else { return }
        _safeFrame = window.bounds.inset(by: window.safeAreaInsets)
    }
    
    func moveToBorder(animated: Bool) {
        isUserInteractionEnabled = false
        _isPanning = false
        isTouching = false
        
        var frame = self.frame
        let isToLeft = frame.midX <= _safeFrame.midX
        frame.origin.x = isToLeft ? (_safeFrame.minX + Self.safeMargin) : (_safeFrame.maxX - frame.width - Self.safeMargin)
        frame = _markSafeFrame(frame, isMoving: false)
        
        guard animated else {
            self.frame = frame
            isUserInteractionEnabled = true
            return
        }
        
        UIView.animate(withDuration: 0.55, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 1, options: []) {
            self.frame = frame
        } completion: { _ in
            self.isUserInteractionEnabled = true
        }
    }
}
