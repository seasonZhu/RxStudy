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
        let isOnWindow = shared.superview == FunWindow.shared
        FunWindow.shared.show()
        if !isOnWindow {
            FunWindow.shared.addSubview(shared)
        }
        shared.updateSafeFrame()
        shared.moveToBorder(animated: isOnWindow)
    }
    
    /// 展示`FunnyButton`
    static func show() {
        guard shared.superview != FunWindow.shared else { return }
        updateLayout()
    }
    
    /// 替换单个`Action`
    static func replaceAction(_ work: @escaping () -> ()) {
        replaceActions([FunnyAction(work: work)])
    }
    
    /// 替换所有`Action`
    static func replaceActions(_ actions: [FunnyAction]?) {
        show()
        shared.actions = actions.map { $0.count > 0 ? $0 : nil } ?? nil
    }
    
    /// 添加多个`Action`
    static func addActions(_ actions: [FunnyAction]) {
        guard actions.count > 0 else { return }
        show()
        var currentActions = shared.actions ?? []
        currentActions.append(contentsOf: actions)
        shared.actions = currentActions
    }
    
    /// 带条件移除目标`Action`（`decide`返回`true`则删除）
    static func removeActions(where decide: (FunnyAction) -> Bool) {
        guard let actions = shared.actions, actions.count > 0 else { return }
        show()
        shared.actions = actions.filter { !decide($0) }
    }
}

// MARK: - 公用接口
public extension NSObject {
    /// 替换单个`Action`
    @objc func replaceFunnyAction(work: @escaping () -> ()) {
        FunnyButton.replaceAction(work)
    }
    
    /// 替换所有`Action`
    @objc func replaceFunnyActions(_ actions: [FunnyAction]) {
        FunnyButton.replaceActions(actions)
    }
    
    /// 添加单个`Action`
    @objc func addFunnyAction(name: String? = nil, work: @escaping () -> ()) {
        FunnyButton.addActions([FunnyAction(name: name, work: work)])
    }
    
    /// 添加多个`Action`
    @objc func addFunnyActions(_ actions: [FunnyAction]) {
        FunnyButton.addActions(actions)
    }
    
    /// 带条件移除目标`Action`（`decide`返回`true`则删除）
    @objc func removeFunnyActions(where decide: (FunnyAction) -> Bool) {
        FunnyButton.removeActions(where: decide)
    }
    
    /// 移除所有`Action`
    @objc func removeFunnyActions() {
        FunnyButton.replaceActions(nil)
    }
    
    /// 刷新`FunnyButton`布局
    @objc func updateFunnyLayout() {
        FunnyButton.updateLayout()
    }
}

