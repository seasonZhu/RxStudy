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
        //setupUI()
        contentScrollViewLayout()
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
        redButton.rx.tap.subscribe(onNext: { [weak self, weak redButton] (_) in
            
            /// 避免循环引用使用了weak修饰,guard一把
            guard let self, let redButton else { return }
            
            /// 注意这里使用的是update
            redButton.snp.remakeConstraints { (make) in
                make.top.equalToSuperview().offset(200)
                make.leading.equalToSuperview().offset(50)
                make.trailing.equalToSuperview().offset(-50)
                /*
                /// low格写法
                make.right.equalTo(-kScreenWidth * 0.33 - 25)
                /// 逼格写法
                make.trailing.equalToSuperview().multipliedBy(0.67).inset(25)
                 */
            }
        })
        .disposed(by: rx.disposeBag)
        
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
    
    private func contentScrollViewLayout() {
        view.backgroundColor = .white
        
        let contentScrollView = ContentScrollView(scrollDirection: .horizontal, frame: .zero)
        contentScrollView.showsVerticalScrollIndicator = false
        contentScrollView.showsHorizontalScrollIndicator = false
        view.addSubview(contentScrollView)
        contentScrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        for i in 0...9 {
            let x: CGFloat
            let y: CGFloat
            
            switch contentScrollView.scrollDirection {
                
            case .vertical:
                x = 0
                y = CGFloat(i * 100)
            case .horizontal:
                x = CGFloat(i * 100)
                y = 0
            case .both:
                x = CGFloat(i * 100)
                y = CGFloat(i * 100)
            }
            
            let some = UIView(frame: CGRect(x: x, y: y, width: 100, height: 100))
            some.backgroundColor = .random
            some.tag = 100 + i
            
            contentScrollView.addSubview(some)
        }
    }

}

/// 这种形式更新约束的动画效果更好
class SnapKitLayoutAnimationController: UIViewController {
     
    lazy var box = UIView()
     
    var scacle = 1.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
         
        /// 单击监听
        let tapSingle = UITapGestureRecognizer(target:self,action:#selector(tapSingleDid))
        tapSingle.numberOfTapsRequired = 1
        tapSingle.numberOfTouchesRequired = 1
        view.addGestureRecognizer(tapSingle)
         
        box.backgroundColor = UIColor.orange
        view.addSubview(box)
         
        box.snp.makeConstraints { (make) -> Void in
            make.center.equalTo(view)
            /// 初始宽、高为100（优先级低）
            make.width.height.equalTo(100 * self.scacle).priority(.low);
            /// 最大尺寸不能超过屏幕
            make.width.height.lessThanOrEqualTo(self.view.snp.width)
            make.width.height.lessThanOrEqualTo(self.view.snp.height)
        }
    }
     
    //视图约束更新
    override func updateViewConstraints() {
        self.box.snp.updateConstraints{ (make) -> Void in
            /// 放大尺寸（优先级低）
            make.width.height.equalTo(100 * self.scacle).priority(.low);
        }
         
        super.updateViewConstraints()
    }
     
    //点击屏幕
    @objc
    func tapSingleDid(){
        self.scacle += 0.1
        /// 告诉self.view约束需要更新
        self.view.setNeedsUpdateConstraints()
        /// 动画
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
}

