//
//  HotKeyController.swift
//  RxStudy
//
//  Created by season on 2021/5/28.
//  Copyright © 2021 season. All rights reserved.
//

import UIKit

class HotKeyController: BaseViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        self.view.backgroundColor = .white
        self.title = "热词"
        
        let viewModel = HotKeyViewModel(disposeBag: rx.disposeBag)
        
        viewModel.inputs.loadData()
        
        viewModel.outputs.dataSource.asDriver().drive { [weak self] hotKeys in
            self?.tagLayout(hotKeys: hotKeys)
        }.disposed(by: rx.disposeBag)
    }
    
    private func tagLayout(hotKeys: [HotKey]) {
        let textPadding: CGFloat = 10.0
        let texts = hotKeys.map { $0.name }.compactMap {  $0 }
        
        let tuples = texts.map { title -> (UIButton, CGFloat) in
            let button = UIButton(type: .custom)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
            button.setTitle(title, for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = .systemBlue
            button.layer.cornerRadius = 4
            button.layer.masksToBounds = true
            
            button.rx.tap.subscribe { _ in
                print(title)
            }.disposed(by: rx.disposeBag)

            
            let width = title.size(withFont: (button.titleLabel?.font)!).width + textPadding * 2
            return (button, width)
        }
        
        let buttons = tuples.map { $0.0 }
        let textWidths = tuples.map { $0.1 }
        
        
        let _ = tuples.map {
            self.view.addSubview($0.0)
        }
        
        // verticalSpacing   每个view之间的垂直距离
        // horizontalSpacing 每个view之间的水平距离
        // maxWidth 是整个布局的最大宽度，需要事前传入，比如 self.view.bounds.size.width - 40
        // textWidth 是每个view的宽度，也需事前计算好
        // itemHeight 每个view的高度
        // edgeInset 整个布局的 上下左右边距，默认为 .zero
        // topConstrainView 整个布局之上的view, 从topConstrainView.snp.bottom开始计算，
        // 比如,传入上面的label,则从 label.snp.bottom + edgeInset.top 开始排列， 默认为nil, 此时布局从 superview.snp.top + edgeInset.top 开始计算
        buttons.snp.distributeDetermineWidthViews(verticalSpacing: 20,
                                                  horizontalSpacing: 10,
                                                  maxWidth: view.bounds.size.width - 40,
                                                  determineWidths: textWidths, itemHeight: 30,
                                                  edgeInset: UIEdgeInsets(top: 20 + UIApplication.shared.statusBarFrame.height + 44,
                                                                          left: 16,
                                                                          bottom: 0,
                                                                          right: 16))
    }
}
