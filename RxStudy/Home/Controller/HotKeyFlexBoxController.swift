//
//  HotKeyFlexBoxController.swift
//  RxStudy
//
//  Created by dy on 2025/5/12.
//  Copyright © 2025 season. All rights reserved.
//

import UIKit

import RxSwift
import RxSwiftExt
import RxCocoa

import FlexLayout

class HotKeyFlexBoxController: BaseViewController {
    
    private lazy var textField: UITextField = {
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width - 40, height: 34))
        textField.textColor = .black
        textField.layer.borderWidth = 0.5
        textField.layer.borderColor = UIColor.gray.cgColor
        textField.layer.cornerRadius = 17
        textField.layer.masksToBounds = true
        textField.backgroundColor = .white
        textField.returnKeyType = .search
        textField.font = UIFont.systemFont(ofSize: 15)
        
        let emptyView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 1))
        textField.leftView = emptyView
        textField.rightView = emptyView
        textField.leftViewMode = .always
        textField.rightViewMode = .always
        return textField
    }()
    
    private lazy var rootFlexContainer = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        binding()
    }
    
    private func setupUI() {
        
        view.backgroundColor = .playAndroidBackground
        
        view.addSubview(rootFlexContainer)
        
        navigationItem.titleView = textField
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(rightBarButtonItemAction))
    }
    
    private func binding() {
        
        /// 状态可以组合
        textField.rx.controlEvent([.editingDidEndOnExit])
            .asObservable()
            .subscribe(onNext: { [weak self] _ in
                guard let self else { return }
                self.pushToSearchResultController(keyword: self.textField.text!)
            })
            .disposed(by: rx.disposeBag)
        
        navigationItem.rightBarButtonItem?.rx.tap
            .map { [weak self] in self?.textField.text }
            .compactMap { $0 }
            .subscribe(onNext: { [weak self] in
                print("onNext event:\($0)")
                self?.pushToSearchResultController(keyword: $0)
            })
            .disposed(by: rx.disposeBag)
        
        let searchValid = textField.rx.text.orEmpty
                .map { $0.isNotEmpty }
                .share(replay: 1)
        
        searchValid.bind(to: navigationItem.rightBarButtonItem!.rx.isEnabled).disposed(by: rx.disposeBag)

        let viewModel = HotKeyViewModel()
        
        viewModel.inputs.loadData()
    
        /// 3.这里的dataSource是一个BehaviorRelay,最好将一次的空数据跳过,减少不必要的layout
        viewModel.outputs.dataSource.skip(1)
            .subscribe(onNext: { [weak self] in
                self?.flexLayoutWrap(hotKeys: $0)
            })
            .disposed(by: rx.disposeBag)
        
        viewModel.outputs.networkError
            .bind(to: rx.networkError)
            .disposed(by: rx.disposeBag)
        
        errorRetry
            .bind(onNext: viewModel.inputs.loadData)
            .disposed(by: rx.disposeBag)
    }
    
    private func pushToSearchResultController(keyword: String) {
        let vc = SearchResultController(keyword: keyword)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc
    private func rightBarButtonItemAction() {
        print("rightBarButtonItemAction")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        rootFlexContainer.flex.margin(view.safeAreaInsets)
        rootFlexContainer.frame = view.bounds
        rootFlexContainer.flex.layout()
    }
}

extension HotKeyFlexBoxController {
    fileprivate func flexLayoutWrap(hotKeys: [HotKey]) {
        let texts = hotKeys.map { $0.name }.compactMap { $0 }
        
        let buttons = texts.map { title -> (UIButton) in
            let button = UIButton(type: .custom)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 15)
            button.setTitle(title, for: .normal)
            button.setTitleColor(.white, for: .normal)
            button.backgroundColor = .systemBlue
            button.layer.cornerRadius = 4
            button.layer.masksToBounds = true
            
            button.rx.tap
                .map { title }
                .subscribeNext(weak: self) { (self) in { self.pushToSearchResultController(keyword: $0) }}
                .disposed(by: rx.disposeBag)
            return button
        }
        
//        rootFlexContainer.flex.define { flex in
//            /// 1.在根容器里面创建一个row的wrap进行布局
//            flex.addItem().direction(.row).wrap(.wrap).marginTop(20).marginHorizontal(10).define { flex in
//                buttons.forEach {
//                    flex.addItem($0).height(30).marginRight(20).marginBottom(20).paddingHorizontal(10)
//                }
//            }
//        }
        
        /// 1. 将根Flex作为一个横向的wrap进行布局,只是设置的margin无法生效,但是可以退一步使用padding
        rootFlexContainer.flex.direction(.row).wrap(.wrap).paddingTop(20).paddingHorizontal(10).define { flex in
            buttons.forEach {
                flex.addItem($0).height(30).marginRight(20).marginBottom(20).paddingHorizontal(10)
            }
        }
        
        /// 2.因为是在网络请求之后进行布局,所以需要进行布局更新,可以认为是Flutter里面的setState
        rootFlexContainer.flex.layout()
    }
}
