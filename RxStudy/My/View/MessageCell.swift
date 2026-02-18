//
//  MessageCell.swift
//  RxStudy
//
//  Created by dy on 2022/6/27.
//  Copyright © 2022 season. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

class MessageCell: UITableViewCell {
    
    private lazy var countLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 11
        label.textColor = .white
        label.backgroundColor = .red
        return label
    }()
    
    var count: Int {
        
        set {
            _count = newValue
            countLabel.text = newValue > 99 ? "99+" : newValue.toString
            countLabel.isHidden = !newValue.greaterThanZero
            
        } get {
            return _count
        }
        
    }
    
    private var _count: Int!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension MessageCell {
    private func setupUI() {
        contentView.addSubview(countLabel)
        countLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.width.height.equalTo(22)
            make.trailing.equalToSuperview().offset(-15)
        }
    }
}

extension Reactive where Base == MessageCell {
    var count: Binder<Int> {
        return Binder(base) { cell, count in
            cell.count = count
        }
    }
}
