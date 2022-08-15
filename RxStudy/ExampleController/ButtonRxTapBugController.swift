//
//  ButtonRxTapBugController.swift
//  RxStudy
//
//  Created by dy on 2022/8/15.
//  Copyright © 2022 season. All rights reserved.
//

import UIKit

import RxCocoa

class ButtonRxTapBugController: BaseViewController {
    
    private lazy var redButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = .red
        return button
    }()
    
    private lazy var blueButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = .blue
        return button
    }()
    
    private let isEnableRelay = BehaviorRelay(value: true)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        view.addSubview(redButton)
        redButton.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(100)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(44)
        }
        
        view.addSubview(blueButton)
        blueButton.snp.makeConstraints { (make) in
            make.top.equalTo(redButton.snp.bottom).offset(20)
            make.leading.trailing.height.equalTo(redButton)
        }
        
        /// 并不是所有的button.rx.tap.subscribe都会出现这种异常
        redButton.rx.tap.subscribe {
            print("event: \($0)")
        }.disposed(by: rx.disposeBag)
        
        blueButton.rx.tap
            .map { [weak self] in !(self?.isEnableRelay.value ?? true) }
            .bind(to: isEnableRelay).disposed(by: rx.disposeBag)
        
        isEnableRelay.bind(to: redButton.rx.isEnabled).disposed(by: rx.disposeBag)
    }
}
