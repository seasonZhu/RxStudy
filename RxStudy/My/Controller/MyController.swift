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
import SVProgressHUD

class MyController: BaseTableViewController {
    
    let vm = CombineCoinRankListViewModel()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        //AccountManager.shared.autoLogin()
    }
    
    private func setupUI() {
        tableView.mj_header = nil
        tableView.mj_footer = nil
        
        tableView.emptyDataSetSource = nil
        tableView.emptyDataSetDelegate = nil
        
        tableView.rowHeight = 44
        
        let myView = MyView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenWidth_9_16))
        tableView.tableHeaderView = myView
        
        let viewModel = MyViewModel()

        viewModel.outputs.currentDataSource.asDriver()
            .drive(tableView.rx.items) { (tableView, row, my) in
                let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.className)!
                cell.textLabel?.text = my.title
                cell.accessoryType = my.accessoryType
                my.layout(cell)
                return cell
            }
            .disposed(by: rx.disposeBag)
        
        viewModel.outputs.myCoin
            .bind(to: myView.rx.myInfo)
            .disposed(by: rx.disposeBag)
        
        /// 这里相当于重写
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
        guard let nameSpace = nameSpace else {
            return nil
        }
        
        guard let `class` = NSClassFromString(nameSpace + "." + className),
              let typeClass = `class` as? T.Type else {
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
                        //AccountManager.shared.myCoin.accept(nil)
                        DispatchQueue.main.async {
                            SVProgressHUD.showText("退出登录成功")
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

extension MyController {
    private func moya_combineHttpRequest() {
        vm.getMyCoinList(page: 1)
    }
}
