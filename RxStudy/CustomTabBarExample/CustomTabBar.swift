//
//  CustomTabBar.swift
//  CustomTabBarExample
//
//  Created by Jędrzej Chołuj on 18/12/2021.
//

import UIKit

import RxSwift
import RxCocoa
import RxGesture

final class CustomTabBar: UIStackView {
    
    private lazy var customItemViews = CustomTabItem.allCases.map { $0.customItemView }
    
    let itemTappedRelay = PublishRelay<Int>()
    
    init() {
        super.init(frame: .zero)
        
        setupHierarchy()
        setupProperties()
        bind()
        
        setNeedsLayout()
        layoutIfNeeded()
        selectItem(index: 0)
    }
    
    deinit {
        deinitDDLog()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupHierarchy() {
        addArrangedSubviews(customItemViews)
    }
    
    private func setupProperties() {
        distribution = .fillEqually
        alignment = .center
        
        backgroundColor = .systemIndigo
        setupCornerRadius(30)
        
        customItemViews.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.clipsToBounds = true
        }
    }
    
    private func selectItem(index: Int) {
        customItemViews.forEach { $0.isSelected = $0.item.index == index }
        itemTappedRelay.accept(index)
    }
    
    // MARK: - Bindings
    
    private func bind() {
        customItemViews.forEach { itemView in
            itemView.rx.tapGesture().when(.recognized).bind { [weak self] _ in
                self?.selectItem(index: itemView.item.index)
            }.disposed(by: rx.disposeBag)
        }
    }
}
