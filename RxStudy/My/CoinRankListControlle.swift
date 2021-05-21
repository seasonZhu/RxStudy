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
import SnapKit

class CoinRankListController: BaseViewController {
    
    private lazy var tableView = UITableView(frame: .zero, style: .plain)
    
    var dataSource: Observable<[String]>!

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
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(self.view)
        }
            
//        //1.创建可观察数据源
//        var texts = ["Objective-C", "Swift", "RXSwift"]
//        let textsObservable = Observable.from(optional: texts)
//        //2. 将数据源与 tableView 绑定
//        textsObservable.bind(to: tableView.rx.items(cellIdentifier: "Cell", cellType: UITableViewCell.self)) { (row, text, cell) in
//                cell.textLabel?.text = text
//        }
//            .disposed(by: disposeBag)
        //3. 绑定 tableView 的事件
        tableView.rx.itemSelected.bind { (indexPath) in
                print(indexPath)
            
        }
            .disposed(by: disposeBag)
        
        //4. 设置 tableView Delegate/DataSource 的代理方法
        tableView.rx.setDelegate(self).disposed(by: disposeBag)
        
        myProvider.rx.request(MyService.coinRank(1)).map(BaseModel<Page<CoinRank>>.self)
            .map{ $0.data?.datas?.map{ $0.rankInfo }
                
            }.compactMap{ $0 }
            .subscribe(onSuccess: { model in
                print(model)
                self.dataSource = Observable.from(optional: model)
                
                self.dataSource.bind(to: self.tableView.rx.items(cellIdentifier: "Cell", cellType: UITableViewCell.self)) { (row, text, cell) in
                        cell.textLabel?.text = text
                }
                .disposed(by: self.disposeBag)
            }, onError: { error in
                print(error)
                
            }).disposed(by: disposeBag)
    }
}

extension CoinRankListController: UITableViewDelegate {
    
}
