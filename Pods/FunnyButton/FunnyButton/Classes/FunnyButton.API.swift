//
//  FunnyButton.API.swift
//  FunnyButton
//
//  Created by aa on 2022/9/17.
//
//  公开接口

public extension FunnyButton {
    /// 刷新`FunnyButton`布局
    static func updateLayout() {
#if DEBUG
        let isOnWindow = shared.superview == FunWindow.shared
        FunWindow.shared.show()
        if !isOnWindow {
            FunWindow.shared.addSubview(shared)
        }
        shared.updateSafeFrame()
        shared.moveToBorder(animated: isOnWindow)
#endif
    }
    
    /// 展示`FunnyButton`
    static func show() {
#if DEBUG
        guard shared.superview != FunWindow.shared else { return }
        updateLayout()
#endif
    }
    
    /// 替换单个`Action`
    static func replaceAction(_ work: @escaping () -> ()) {
#if DEBUG
        replaceActions([FunnyAction(work: work)])
#endif
    }
    
    /// 替换所有`Action`
    static func replaceActions(_ actions: [FunnyAction]?) {
#if DEBUG
        show()
        shared.actions = actions.map { $0.count > 0 ? $0 : nil } ?? nil
#endif
    }
    
    /// 添加多个`Action`
    static func addActions(_ actions: [FunnyAction]) {
#if DEBUG
        guard actions.count > 0 else { return }
        show()
        var currentActions = shared.actions ?? []
        currentActions.append(contentsOf: actions)
        shared.actions = currentActions
#endif
    }
    
    /// 带条件移除目标`Action`（`decide`返回`true`则删除）
    static func removeActions(where decide: (FunnyAction) -> Bool) {
#if DEBUG
        guard let actions = shared.actions, actions.count > 0 else { return }
        show()
        shared.actions = actions.filter { !decide($0) }
#endif
    }
}

// MARK: - 公用接口
public extension NSObject {
    /// 替换单个`Action`
    @objc func replaceFunnyAction(work: @escaping () -> ()) {
#if DEBUG
        FunnyButton.replaceAction(work)
#endif
    }
    
    /// 替换所有`Action`
    @objc func replaceFunnyActions(_ actions: [FunnyAction]) {
#if DEBUG
        FunnyButton.replaceActions(actions)
#endif
    }
    
    /// 添加单个`Action`
    @objc func addFunnyAction(name: String? = nil, work: @escaping () -> ()) {
#if DEBUG
        FunnyButton.addActions([FunnyAction(name: name, work: work)])
#endif
    }
    
    /// 添加多个`Action`
    @objc func addFunnyActions(_ actions: [FunnyAction]) {
#if DEBUG
        FunnyButton.addActions(actions)
#endif
    }
    
    /// 带条件移除目标`Action`（`decide`返回`true`则删除）
    @objc func removeFunnyActions(where decide: (FunnyAction) -> Bool) {
#if DEBUG
        FunnyButton.removeActions(where: decide)
#endif
    }
    
    /// 移除所有`Action`
    @objc func removeFunnyActions() {
#if DEBUG
        FunnyButton.replaceActions(nil)
#endif
    }
    
    /// 刷新`FunnyButton`布局
    @objc func updateFunnyLayout() {
#if DEBUG
        FunnyButton.updateLayout()
#endif
    }
}

