//
//  CustomItemView.swift
//  CustomTabBarExample
//
//  Created by Jędrzej Chołuj on 18/12/2021.
//

import UIKit
import SnapKit

final class CustomItemView: UIView {
    
    private lazy var nameLabel = UILabel()
    
    private lazy var iconImageView = UIImageView()
    
    private lazy var underlineView = UIView()
    
    private lazy var containerView = UIView()
    
    var isSelected = false {
        didSet {
            animateItems()
        }
    }
    
    let item: CustomTabItem
    
    init(with item: CustomTabItem) {
        self.item = item
        
        super.init(frame: .zero)
        
        setupHierarchy()
        setupLayout()
        setupProperties()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        deinitDDLog()
    }
    
    private func setupHierarchy() {
        addSubview(containerView)
        containerView.addSubviews(nameLabel, iconImageView, underlineView)
    }
    
    private func setupLayout() {
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.center.equalToSuperview()
        }
        
        iconImageView.snp.makeConstraints {
            $0.height.width.equalTo(40)
            $0.top.equalToSuperview()
            $0.bottom.equalTo(nameLabel.snp.top)
            $0.centerX.equalToSuperview()
        }
        
        nameLabel.snp.makeConstraints {
            $0.bottom.leading.trailing.equalToSuperview()
            $0.height.equalTo(16)
        }
        
        underlineView.snp.makeConstraints {
            $0.width.equalTo(40)
            $0.height.equalTo(4)
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(nameLabel.snp.centerY)
        }
    }
    
    private func setupProperties() {
        nameLabel.configureWith(item.name,
                                color: .white.withAlphaComponent(0.4),
                                alignment: .center,
                                size: 11,
                                weight: .semibold)
        underlineView.backgroundColor = .white
        underlineView.setupCornerRadius(2)
        
        iconImageView.image = isSelected ? item.selectedIcon : item.icon
    }
    
    private func animateItems() {
        UIView.animate(withDuration: 0.4) { [unowned self] in
            self.nameLabel.alpha = self.isSelected ? 0.0 : 1.0
            self.underlineView.alpha = self.isSelected ? 1.0 : 0.0
        }
        UIView.transition(with: iconImageView,
                          duration: 0.4,
                          options: .transitionCrossDissolve) { [unowned self] in
            self.iconImageView.image = self.isSelected ? self.item.selectedIcon : self.item.icon
        }
    }
}
