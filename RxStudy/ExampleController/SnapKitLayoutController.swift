//
//  SnapKitLayoutController.swift
//  RxStudy
//
//  Created by dy on 2021/7/19.
//  Copyright © 2021 season. All rights reserved.
//

import UIKit

import SnapKit
import RxCocoa

class SnapKitLayoutController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        title = "SnapKit的简单布局"
        
        view.backgroundColor = .white
        
        let redButton = UIButton(type: .custom)
        redButton.backgroundColor = .red
        
        view.addSubview(redButton)
        redButton.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(100)
            make.leading.equalToSuperview().offset(16)
            make.trailing.equalToSuperview().offset(-16)
            make.height.equalTo(44)
        }
        
        /// 按钮的点击事件,更新布局
        redButton.rx.tap.subscribe { [weak self, weak redButton] (_) in
            
            /// 避免循环引用使用了weak修饰,guard一把
            guard let self, let redButton else { return }
            
            /// 注意这里使用的是update
            redButton.snp.remakeConstraints { (make) in
                make.top.equalToSuperview().offset(200)
                make.leading.equalToSuperview().offset(50)
                make.trailing.equalToSuperview().offset(-50)
            }
        }.disposed(by: rx.disposeBag)
        
        let blueButton = UIButton(type: .custom)
        blueButton.backgroundColor = .blue
        
        view.addSubview(blueButton)
        /// blue的布局完全都是依赖与redButton
        blueButton.snp.makeConstraints { (make) in
            make.top.equalTo(redButton.snp.bottom).offset(20)
            make.leading.trailing.height.equalTo(redButton)
        }
        
        /**
         view.addSubview(blueButton)
         blueButton.snp.makeConstraints { (make) in
             make.top.equalTo(view).offset(100)
             make.leading.equalTo(view).offset(16)
             make.trailing.equalTo(view).offset(-16)
             make.height.equalTo(44)
         }
         */
    }

}
