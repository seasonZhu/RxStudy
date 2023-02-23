//
//  ButtonRxTapBugController.swift
//  RxStudy
//
//  Created by dy on 2022/8/15.
//  Copyright © 2022 season. All rights reserved.
//

import UIKit

import RxCocoa

import SnapKit

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
        }
        .disposed(by: rx.disposeBag)
        
        blueButton.rx.tap
            .map { [weak self] in !(self?.isEnableRelay.value ?? true) }
            .bind(to: isEnableRelay)
            .disposed(by: rx.disposeBag)
        
        blueButton.rx.tap.subscribe { [weak self] _ in
            self?.dismiss(animated: true)
        }
        .disposed(by: rx.disposeBag)
        
        isEnableRelay.bind(to: redButton.rx.isEnabled).disposed(by: rx.disposeBag)
    }
}

/*
 最近在看UIScrollView + UIStackView配合替代UITableView的方案
 http://octotap.com/2019/08/03/uistackview-inside-uiscrollview/
 https://zirkler.medium.com/uikit-programmatically-embed-a-uistackview-in-an-uiscrollview-using-autolayout-fd4e97ce8f26
 */
class ScrollableStackController: BaseViewController {

    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        return stackView
    }()
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    /// 圆形
    var circle: UIView {
        let circle = UIView()
        circle.translatesAutoresizingMaskIntoConstraints = true
        circle.widthAnchor.constraint(equalToConstant: 200).isActive = true
        circle.heightAnchor.constraint(equalToConstant: 200).isActive = true
        circle.backgroundColor = .random
        circle.layer.cornerRadius = 100
        circle.layer.masksToBounds = true
        return circle
    }
    
    /// 标题
    var titleLabel: UILabel {
        let label = UILabel()
        label.text = "UIStackView inside UIScrollView."
        label.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        label.textColor = .white
        label.textAlignment = .center
        label.backgroundColor = .random
        return label
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "UIScrollView + UIStackView"
        
        //horizontalLayout()
        verticalLayout()
    }
    
    private func horizontalLayout() {
        stackView.axis = .horizontal
        stackView.spacing = 20
        stackView.alignment = .center
        
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        scrollView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        for _ in 0..<20 {
            stackView.addArrangedSubview(circle)
        }
    }
    
    private func verticalLayout() {
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .fill
        
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        let contentView = UIView()
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(kScreenWidth)
        }
        
        contentView.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.bottom.equalTo(contentView.snp.bottom).offset(0)
        }
        
        for _ in 0..<20 {
            stackView.addArrangedSubview(circle)
        }
    }
}
