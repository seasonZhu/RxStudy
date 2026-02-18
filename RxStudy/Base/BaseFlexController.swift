//
//  BaseFlexController.swift
//  RxStudy
//
//  Created by dy on 2025/11/19.
//  Copyright © 2025 season. All rights reserved.
//

import UIKit

import FlexLayout
import PinLayout

import MJRefresh

// MARK: - 模版
class BaseFlexController: BaseViewController {
    
    lazy var contentView = UIScrollView()
    
    lazy var rootFlexContainer = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        contentView.mj_header = nil
        
        rootFlexContainer.backgroundColor = .clear
        
        contentView.addSubview(rootFlexContainer)
        
        view.addSubview(contentView)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
                
        // 1) Layout the contentView & rootFlexContainer using PinLayout
        contentView.frame = view.bounds
        rootFlexContainer.pin.top().left().right().bottom()
        
        // 2) Let the flexbox container layout itself and adjust the height
        rootFlexContainer.flex.layout(mode: .adjustHeight)
        
        // 3) Adjust the scrollview contentSize
        contentView.contentSize = rootFlexContainer.frame.size
    }
}

class BaseFlexView: UIView {
    lazy var rootFlexContainer = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = .clear
        addSubview(rootFlexContainer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        rootFlexContainer.pin.all()
        
        rootFlexContainer.flex.layout(mode: .fitContainer)
    }
}

// MARK: - 例子
class FlexTestController: BaseFlexController {
    
    private lazy var testView = FlexTestView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        rootFlexContainer.flex.marginTop(kTopMargin).define { flex in
            flex.addItem().backgroundColor(.red).height(44)
            flex.addItem(testView).height(100).marginTop(20)
        }
    }
}

class FlexTestView: BaseFlexView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        rootFlexContainer.flex.direction(.row).define { flex in
            flex.addItem().grow(1).backgroundColor(.red)
            flex.addItem().grow(2).backgroundColor(.yellow)
            flex.addItem().grow(3).backgroundColor(.blue)
        }
    }
}
