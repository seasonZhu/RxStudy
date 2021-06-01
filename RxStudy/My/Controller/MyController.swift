//
//  MyController.swift
//  RxStudy
//
//  Created by season on 2021/6/1.
//  Copyright © 2021 season. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

class MyController: BaseTableViewController {
    
    let logoutDataSource = ["排行榜", "开源框架引用", "登录"]
    
    let loginDataSource = ["排行榜", "开源框架引用", "我的积分", "我的收藏", "登出"]
    
    var currentDataSource = BehaviorRelay<[String]>(value: [])
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        AccountManager.shared.isLogin.subscribe(onNext: { isLogin in
            print("\(self.className)收到了关于登录状态的值")
            self.currentDataSource.accept(isLogin ? self.loginDataSource : self.logoutDataSource)
            self.tableView.reloadData()
        }).disposed(by: rx.disposeBag)
    }
    
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        tableView.mj_header = nil
        tableView.mj_footer = nil
        
        tableView.emptyDataSetSource = nil
        tableView.emptyDataSetDelegate = nil
        
        let isLogin = AccountManager.shared.isLogin.value
        self.currentDataSource.accept(isLogin ? self.loginDataSource : self.logoutDataSource)
            
        currentDataSource.asDriver(onErrorJustReturn: [])
            .drive(tableView.rx.items) { (tableView, row, text) in
                if let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") {
                    cell.textLabel?.text = text
                    return cell
                }else {
                    let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
                    cell.textLabel?.text = text
                    return cell
                }
            }
            .disposed(by: rx.disposeBag)
    }
}
