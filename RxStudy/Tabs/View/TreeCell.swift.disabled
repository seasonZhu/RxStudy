//
//  TreeCell.swift
//  RxStudy
//
//  Created by dy on 2025/5/19.
//  Copyright © 2025 season. All rights reserved.
//

import UIKit

import RxRelay
import RxCocoa

import FlexLayout

class TreeCell: BaseDisposeBagCell {
    
    let buttonTap = PublishRelay<TabModel>()
    
    var model: TabModel! {
        set {
            wrapLayout(model: newValue)
        } get {
            return _model
        }
    }
    
    private var _model: TabModel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 这个方法必须要,否则cell布局以及高度都乱了
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        contentView.frame.size = size
        
        layout()
        
        return contentView.frame.size
    }
    
    /// 在layoutSubviews进行布局与刷新
    override func layoutSubviews() {
        // layout()
    }

    /// 先sizeThatFits
    /// 后layoutSubviews
    /// 都会调用
    /// 所以我认为在layoutSubviews里面刷新就可以了 ❌
    /// sizeThatFits调用layout()方法可以保证布局不乱 ✅
    /// sizeThatFits()里面不调用layout(),只在layoutSubviews()里面调用layout(),布局会乱
    
}

extension TreeCell {
    private func setupUI() {

    }
    
    fileprivate func wrapLayout(model: TabModel) {
        guard let children = model.children else {
            return
        }
        
        contentView.flex.removeAllElement()
        
        let buttons = children.map { model -> (UIButton) in
            let button = UIButton(type: .custom)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
            button.setTitle(model.name, for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = .random
            button.layer.cornerRadius = 4
            button.layer.masksToBounds = true
            
            button.rx.tap
                .subscribe(onNext: { [weak self] in
                    self?.buttonTap.accept(model)
                })
                .disposed(by: disposeBag)
            
            return button
        }
        
        /// 将根Flex作为一个横向的wrap进行布局,只是设置的margin无法生效,但是可以退一步使用padding
        contentView.flex.direction(.row).wrap(.wrap).padding(16).define { flex in
            buttons.forEach {
                flex.addItem($0).height(30).paddingHorizontal(10).marginRight(20).marginBottom(20)
            }
        }
        
        /// 这里可能会导致奔溃
        // contentView.flex.markDirty()
        
        /// 因为是在网络请求之后进行布局,所以需要进行布局更新,可以认为是Flutter里面的setState
        layout()
    }
    
    /// 刷新
    private func layout() {
        contentView.flex.layout(mode: .adjustHeight)
    }
}
