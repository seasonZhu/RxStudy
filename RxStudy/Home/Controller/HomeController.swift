//
//  HomeController.swift
//  RxStudy
//
//  Created by season on 2021/5/25.
//  Copyright © 2021 season. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa
import NSObject_Rx
import SnapKit
import MJRefresh
import Kingfisher

class HomeController: BaseViewController {
    
    private lazy var tableView = UITableView(frame: .zero, style: .plain)
        
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "积分排名"
        view.backgroundColor = .white
        setupUI()
    }
}

extension HomeController {
    private func setupUI() {
        /// 设置代理
        tableView.rx.setDelegate(self).disposed(by: rx.disposeBag)
        tableView.estimatedRowHeight = 88
        
        /// 简单布局
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(self.view)
        }
        
        /// 获取indexPath
        tableView.rx.itemSelected
            .bind { [weak self] (indexPath) in
                self?.tableView.deselectRow(at: indexPath, animated: false)
                print(indexPath)
            }
            .disposed(by: rx.disposeBag)
        
        
        /// 获取cell中的模型
        tableView.rx.modelSelected(Info.self)
            .subscribe { model in
            print("模型为:\(model)")
            }
            .disposed(by: rx.disposeBag)
        
        /// 同时获取indexPath和模型
        Observable.zip(tableView.rx.itemSelected, tableView.rx.modelSelected(Info.self))
            .bind { indexPath, model in
                
            }
            .disposed(by: rx.disposeBag)

        /// 设置头部刷新控件
        tableView.mj_header = MJRefreshNormalHeader()
        /// 设置尾部刷新控件
        tableView.mj_footer = MJRefreshBackNormalFooter()
                
        let viewModel = HomeViewModel(disposeBag: rx.disposeBag)

        tableView.mj_header?.rx.refreshAction
            .asDriver()
            .drive(onNext: {
                viewModel.inputs.loadData(actionType: .refresh)
                
            })
            .disposed(by: disposeBag)

        tableView.mj_footer?.rx.refreshAction
            .asDriver()
            .drive(onNext: {
                viewModel.inputs.loadData(actionType: .loadMore)
                
            })
            .disposed(by: disposeBag)

        // 绑定数据
        viewModel.outputs.dataSource
            .asDriver()
            .drive(tableView.rx.items) { [weak self] (tableView, row, info) in
                if let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") {
                    self?.cellSetting(cell: cell, info: info)
                    return cell
                }else {
                    let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
                    self?.cellSetting(cell: cell, info: info)
                    return cell
                }
            }
            .disposed(by: rx.disposeBag)
        
        
        viewModel.outputs.refreshStatusBind(to: tableView)?
            .disposed(by: disposeBag)

        tableView.mj_header?.beginRefreshing()
    }
    
    private func cellSetting(cell: UITableViewCell, info: Info) {
        cell.textLabel?.text = info.title
        cell.textLabel?.numberOfLines = 0
        cell.detailTextLabel?.text = info.author
        cell.detailTextLabel?.textColor = .gray
//        if let imageString = info.envelopePic, let url = URL(string: imageString) {
//            cell.imageView?.kf.setImage(with: url)
//        }
    }
}

extension HomeController: UITableViewDelegate {}
