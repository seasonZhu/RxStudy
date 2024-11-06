//
//  BaseTableViewCell.swift
//  RxStudy
//
//  Created by dy on 2024/11/6.
//  Copyright © 2024 season. All rights reserved.
//

import UIKit

import RxSwift

/// 直接让子类重新方法,这样就不用每次都重写init方法了
class BaseTableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupUI()
        binding()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        
    }
    
    func binding() {
        
    }
}

/// 继承这个类的子类
/// 重写setupUI() binding() setModel(_:)这些方法,来对页面进行页面与逻辑的构建
class BaseGenericsCell<T: Codable>: BaseTableViewCell {
    var model: T {
        get {
            return _model
        } set {
            _model = newValue
            setModel(newValue)
        }
    }
    
    private var _model: T!
    
    func setModel(_ model: T) {
        
    }
}

/// 如果在cell交互中需要使用到cell.disposeBag以打破循环,就需要使用这个类
class BaseGenericsDisposeBagCell<T: Codable>: BaseGenericsCell<T> {
    
    private(set) var disposeBag = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
}
