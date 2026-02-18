//
//  MyView.swift
//  RxStudy
//
//  Created by season on 2021/6/17.
//  Copyright © 2021 season. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import RxGesture

class MyView: UIView {
    
    private lazy var imageView = UIImageView(image: R.image.user())
    
    private lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .playAndroidTitle
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    /// 其实一般的逻辑就是在请求到数据后,通过set方法进行赋值即可
    var myCoin: CoinRank? {
        set {
            _myCoin = newValue
            if let text = newValue?.myInfo {
                imageView.image = R.image.android()
                infoLabel.text = text
            } else {
                imageView.image = R.image.user()
                infoLabel.text = "排名: -- 等级: -- 积分: --"
            }
            
        }
        get {
            return _myCoin
        }
    }
    
    private var _myCoin: CoinRank?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - 搭建界面
    private func setupUI() {
        addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.bottom.equalTo(snp.centerY)
            make.centerX.equalToSuperview()
            make.width.height.equalTo(66)
        }
        imageView.layer.cornerRadius = 33
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 0.5
        imageView.layer.borderColor = UIColor.systemGray.cgColor
        imageView.isUserInteractionEnabled = true
        
        imageView.rx.tapGesture().subscribe(onNext: ({ [weak self] _ in
            self?.bubbleEvent(InnerViewEvent.custom(["name": "season"]))
        })).disposed(by: rx.disposeBag)
        
        addSubview(infoLabel)
        infoLabel.snp.makeConstraints { make in
            make.top.equalTo(snp.centerY).offset(16)
            make.centerX.equalToSuperview()
        }
    }

}

/// 由于我这次使用的Rx,所以是通过这种绑定方式进行,我想正是这种需要自己手写的绑定,所以才限制了iOS中MVVM的困难吧
extension Reactive where Base: MyView {
    var myInfo: Binder<CoinRank?> {
        return Binder(base) { myView, model in
            myView.myCoin = model
        }
    }
}
