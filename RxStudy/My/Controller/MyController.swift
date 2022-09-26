//
//  MyController.swift
//  RxStudy
//
//  Created by season on 2021/6/1.
//  Copyright © 2021 season. All rights reserved.
//

import UIKit
import SwiftUI

import SafariServices

import RxSwift
import RxCocoa
import MBProgressHUD
import SVProgressHUD
import MJRefresh

class MyController: BaseTableViewController {
    
    let combineVM = CombineCoinRankListViewModel()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        /// 将自动登录放在AppDelegate中的didFinishLaunchingWithOptions中,加快获取数据,getMyCoin这个接口返回数据是有点慢
        //AccountManager.shared.autoLogin()
    }
    
    private func setupUI() {
        AccountManager.shared.isLoginRelay.subscribe { [weak self] event in
            switch event {
                
            case .next(let value):
                if value {
                    self?.tableView.mj_header = MJRefreshNormalHeader()
                } else {
                    self?.tableView.mj_header = nil
                }
            default:
                break
            }
        }.disposed(by: rx.disposeBag)
        
        tableView.mj_footer = nil
        
        tableView.emptyDataSetSource = nil
        tableView.emptyDataSetDelegate = nil
        
        tableView.rowHeight = 44
        
        let myView = MyView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenWidth_9_16))
        tableView.tableHeaderView = myView
        
        let viewModel = MyViewModel()
        
        tableView.mj_header?.rx.refresh
            .bind(onNext: viewModel.inputs.loadData)
            .disposed(by: rx.disposeBag)

        viewModel.outputs.currentDataSource.asDriver()
            .drive(tableView.rx.items) { [weak self] (tableView, row, my) in
                if my == .logout {
                    let cell = tableView.dequeueReusableCell(withIdentifier: LogoutCell.className) as! LogoutCell
                    cell.textLabel?.text = my.title
                    cell.accessoryType = my.accessoryType
                    return cell
                } else if my == .myMessage {
                    let cell = tableView.dequeueReusableCell(withIdentifier: MessageCell.className) as! MessageCell
                    cell.textLabel?.text = my.title
                    cell.accessoryType = my.accessoryType
                    
                    if let self {
                        AccountManager.shared.myUnreadMessageCountRelay
                            .bind(to: cell.rx.count)
                            .disposed(by: self.rx.disposeBag)
                    }
                    
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.className)!
                    cell.textLabel?.text = my.title
                    cell.accessoryType = my.accessoryType
                    return cell
                }
            }
            .disposed(by: rx.disposeBag)
        
        AccountManager.shared.myCoinRelay
            .bind(to: myView.rx.myInfo)
            .disposed(by: rx.disposeBag)
        
        /// 下拉与上拉状态绑定到tableView
        viewModel.outputs.refreshSubject
            .bind(to: tableView.rx.refreshAction)
            .disposed(by: rx.disposeBag)
        
        /// 这里相当于重写
        tableView.rx.itemSelected
            .bind { [weak self] (indexPath) in
                self?.tableView.deselectRow(at: indexPath, animated: false)
                let my = viewModel.outputs.currentDataSource.value[indexPath.row]
                switch my {
                case .logout:
                    self?.logoutAction(viewModel: viewModel)
                case .myMessage:
                    self?.toMyMessageController()
                case .myGitHub:
                    /// 尝试使用了SFSafariViewController而非WebView进行加载,对于一个纯粹的展示性Web,SFSafariViewController体验效果更好
                    let sfsVC = SFSafariViewController(url: URL(string: "https://github.com/seasonZhu")!)
                    /// 左侧返回按钮无法自定义,只能使用三个枚举
                    sfsVC.dismissButtonStyle = .close
                    /// 如果这里声明了modalPresentationStyle,又变成了present
                    //sfsVC.modalPresentationStyle = .automatic
                    /// 这里我明明使用的是present,但是在App中还是push的效果,倒是如果使用pushViewController,页面会感觉非常奇葩
                    self?.present(sfsVC, animated: true)
                    //self?.navigationController?.pushViewController(sfsVC, animated: true)
                case .aSwiftUI:
                    self?.navigationController?.pushViewController(UIHostingController(rootView: CoinRankListPage()), animated: true)
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
    
    private func toMyMessageController() {
        let status = AccountManager.shared.myUnreadMessageCountRelay.value.greaterThanZero ? MessageReadyStatus.unread : MessageReadyStatus.read
        navigationController?.pushViewController(MyMessageController(status: status), animated: true)
    }
}

extension MyController {
    private func moyaCombineHttpRequest() {
        combineVM.getMyCoinList(page: 1)
    }
}
