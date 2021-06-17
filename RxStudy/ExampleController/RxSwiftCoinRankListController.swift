//
//  RxSwiftCoinRankListController.swift
//  RxStudy
//
//  Created by season on 2021/6/17.
//  Copyright © 2021 season. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import Moya

class RxSwiftCoinRankListController: BaseViewController {

    lazy var tableView = UITableView(frame: .zero, style: .plain)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    private func setupTableView() {
        
        /// 设置tableFooterView
        tableView.tableFooterView = UIView()
        
        /// 设置代理
        tableView.rx.setDelegate(self).disposed(by: rx.disposeBag)
        
        /// 简单布局
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(self.view)
        }
        
        /// 这里只获取第一页的数据
        myProvider.rx.request(MyService.coinRank(1))
            .map(BaseModel<Page<CoinRank>>.self)
            .map{ $0.data?.datas }
            .compactMap { $0 }
            .asDriver(onErrorJustReturn: [])
            .drive(tableView.rx.items) { (tableView, row, coinRank) in
            if let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") {
                cell.textLabel?.text = coinRank.username
                cell.detailTextLabel?.text = coinRank.coinCount?.toString
                return cell
            }else {
                let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
                cell.textLabel?.text = coinRank.username
                cell.detailTextLabel?.text = coinRank.coinCount?.toString
                return cell
            }
        }
        .disposed(by: rx.disposeBag)
    }

}

extension RxSwiftCoinRankListController: UITableViewDelegate {}
