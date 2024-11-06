//
//  BaseTableViewCell.swift
//  RxStudy
//
//  Created by dy on 2024/11/6.
//  Copyright © 2024 season. All rights reserved.
//

import UIKit

import RxSwift

/// 这个地方如果使用ConstructorProtocol,那么必须在子类重新实现协议方法,再这里实现的方法为空会导致异常
class BaseTableViewCell: UITableViewCell, ConstructorProtocol {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupUI()
        binding()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// 继承这个类的子类
/// 重写setupUI() binding() setModel(_:)这些方法,来对页面进行页面与逻辑的构建
class BaseGenericsCell<T: Codable>: BaseTableViewCell {
    var model: T {
        set {
            _model = newValue
            setModel(newValue)
        } get {
            return _model
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
