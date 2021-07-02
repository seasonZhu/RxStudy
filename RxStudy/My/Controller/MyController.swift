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
import MBProgressHUD

class MyController: BaseTableViewController {
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        AccountManager.shared.autoLogin()
    }
    
    private func setupUI() {
        tableView.mj_header = nil
        tableView.mj_footer = nil
        
        tableView.emptyDataSetSource = nil
        tableView.emptyDataSetDelegate = nil
        
        let myView = MyView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenWidth_9_16))
        tableView.tableHeaderView = myView
        
        let viewModel = MyViewModel()

        viewModel.outputs.currentDataSource.asDriver()
            .drive(tableView.rx.items) { (tableView, row, my) in
                if let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") {
                    cell.textLabel?.text = my.title
                    cell.accessoryType = my.accessoryType
                    return cell
                }else {
                    let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
                    cell.textLabel?.text = my.title
                    cell.accessoryType = my.accessoryType
                    return cell
                }
            }
            .disposed(by: rx.disposeBag)
        
        viewModel.outputs.myCoin
            .bind(to: myView.rx.myInfo)
            .disposed(by: rx.disposeBag)
        
        
        tableView.rx.itemSelected
            .bind { [weak self] (indexPath) in
                self?.tableView.deselectRow(at: indexPath, animated: false)
                let my = viewModel.outputs.currentDataSource.value[indexPath.row]
                switch my {
                case .logout:
                    self?.logoutAction(viewModel: viewModel)
                default:
                    guard let vc = self?.creatInstance(by: my.path) as? UIViewController else {
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
    
    private func logoutAction(viewModel: MyViewModel) {
        let alertController = UIAlertController(title: "提示", message: "是否确定退出登录?", preferredStyle: .alert)
        let actionCancel = UIAlertAction(title: "取消", style: .destructive) { (action) in
            
        }
        let actionOK = UIAlertAction(title: "确定", style: .default) { (action) in
            viewModel.inputs.logout()
                .asDriver(onErrorJustReturn: BaseModel(data: nil, errorCode: nil, errorMsg: nil))
                .drive { baseModel in
                    if baseModel.isSuccess {
                        AccountManager.shared.clearAccountInfo()
                        DispatchQueue.main.async {
                            MBProgressHUD.showText("退出登录成功")
                        }
                    }
                }
                .disposed(by: self.rx.disposeBag)
        }
        alertController.addAction(actionCancel)
        alertController.addAction(actionOK)
        
        present(alertController, animated: true, completion: nil)
    }
}
