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
import AcknowList
import MBProgressHUD

class MyController: BaseTableViewController {
    
    let logoutDataSource: [My] = [.ranking, .openSource, .login]
    
    let loginDataSource: [My] = [.ranking, .openSource, .myCoin, .myCollect, .logout]
    
    var currentDataSource = BehaviorRelay<[My]>(value: [])
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        AccountManager.shared.isLogin.subscribe(onNext: { [weak self] isLogin in
            guard let self = self else { return }
            
            print("\(self.className)收到了关于登录状态的值")
            
            self.currentDataSource.accept(isLogin ? self.loginDataSource : self.logoutDataSource)
            
            if isLogin {
                self.getMyCoin()
            }
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

        currentDataSource.asDriver()
            .drive(tableView.rx.items) { (tableView, row, my) in
                if let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") {
                    cell.textLabel?.text = my.title
                    return cell
                }else {
                    let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
                    cell.textLabel?.text = my.title
                    return cell
                }
            }
            .disposed(by: rx.disposeBag)
        
        
        tableView.rx.itemSelected
            .bind { [weak self] (indexPath) in
                self?.tableView.deselectRow(at: indexPath, animated: false)
                let my = self?.currentDataSource.value[indexPath.row]
                guard let strongMy = my else { return }
                
                switch strongMy {
                case .logout:
                    self?.logoutAction()
                case .openSource:
                    self?.navigationController?.pushViewController(AcknowListViewController(), animated: true)
                default:
                    guard let vc = self?.creatInstance(by: strongMy.path) as? UIViewController else {
                        return
                    }
                    self?.navigationController?.pushViewController(vc, animated: true)
                }
            }
            .disposed(by: rx.disposeBag)
    }
}

extension MyController {
    private func creatInstance<T: NSObject>(by className: String) -> T? {
        guard let nameSpace = Bundle.main.infoDictionary?["CFBundleExecutable"] as? String else {
            return nil
        }
        
        guard let `class` = NSClassFromString(nameSpace + "." + className), let typeClass = `class` as? T.Type else {
            return nil
        }
        return typeClass.init()
    }
    
    private func logoutAction() {
        let alertController = UIAlertController(title: "提示", message: "是否确定退出登录?", preferredStyle: .alert)
        let actionCancel = UIAlertAction(title: "取消", style: .destructive) { (action) in
            
        }
        let actionOK = UIAlertAction(title: "确定", style: .default) { (action) in
            self.logout()
        }
        alertController.addAction(actionCancel)
        alertController.addAction(actionOK)
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func logout() {
        accountProvider.rx.request(AccountService.logout)
            .map(BaseModel<AccountInfo>.self)
            /// 转为Observable
            .asObservable().asSingle().subscribe { baseModel in
                if baseModel.errorCode == 0 {
                    AccountManager.shared.clearAccountInfo()
                    DispatchQueue.main.async {
                        MBProgressHUD.showText("退出登录成功")
                    }
                    self.navigationController?.popToRootViewController(animated: true)
                }
            } onError: { _ in
                
            }.disposed(by: rx.disposeBag)
    }
    
    /// 这个页面,过于简单,感觉不用使用ViewModel
    private func getMyCoin() {
        myProvider.rx.request(MyService.userCoinInfo)
            .map(BaseModel<MyCoin>.self)
            /// 转为Observable
            .asObservable().asSingle().subscribe { baseModel in
                print(baseModel)
            } onError: { _ in
                
            }.disposed(by: rx.disposeBag)
    }
}
