//
//  FunnyAction.swift
//  FunnyButton
//
//  Created by aa on 2022/9/17.
//
//  点击FunnyButton可执行的Action

@objcMembers
public class FunnyAction: NSObject {
    
    /// 名称（用于多个时展示以选择执行）
    let name: String?
    
    /// 执行动作
    let work: () -> ()
    
    public init(name: String? = nil, work: @escaping () -> ()) {
        self.name = name
        self.work = work
        super.init()
    }
    
}
