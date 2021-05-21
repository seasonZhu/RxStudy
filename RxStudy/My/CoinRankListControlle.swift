//
//  CoinRankListController.swift
//  RxStudy
//
//  Created by season on 2021/5/21.
//  Copyright © 2021 season. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import NSObject_Rx
import SnapKit


class CoinRankListController: BaseViewController {
    
    private lazy var tableView = UITableView(frame: .zero, style: .plain)
    
    var dataSource: Observable<[CoinRank]>!
    
    var list: [CoinRank] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "积分排名"
        view.backgroundColor = .white
        setupUI()
    }

    deinit {
        print("被销毁了")
    }
}

extension CoinRankListController {
    func setupUI() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView.rx.setDelegate(self).disposed(by: rx.disposeBag)
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(self.view)
        }
            
        tableView.rx.itemSelected
            .bind { (indexPath) in
                print(indexPath)
//                print(self.list[indexPath.row])
            }
            .disposed(by: rx.disposeBag)
    
        
        dataSource = myProvider.rx.request(MyService.coinRank(1)).map(BaseModel<Page<CoinRank>>.self)
            /// 将BaseModel<Page<CoinRank>转为[CoinRank]
            .map{ $0.data?.datas?.map{ $0 }}
            /// 去掉其中为nil的值
            .compactMap{ $0 }
            /// 转为Observable
            .asObservable()
//            .subscribe(onNext: { list in
//                self.list = list
//            }, onError: { error in
//
//            }, onCompleted: {
//
//            }, onDisposed: {
//
//            }) as? Observable<[CoinRank]>
            
        /// 绑定关系
        dataSource.bind(to: self.tableView.rx.items(cellIdentifier: "Cell", cellType: UITableViewCell.self)) { (row, coinRank, cell) in
            cell.textLabel?.text = coinRank.username
        }
        .disposed(by: rx.disposeBag)
    }
}

extension CoinRankListController: UITableViewDelegate {
    
}
