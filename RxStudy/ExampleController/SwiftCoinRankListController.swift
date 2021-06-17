//
//  SwiftCoinRankListController.swift
//  RxStudy
//
//  Created by season on 2021/6/17.
//  Copyright © 2021 season. All rights reserved.
//

import UIKit

import Moya

class SwiftCoinRankListController: BaseViewController {

    private lazy var tableView = UITableView(frame: .zero, style: .plain)
    
    private var dataSource: [CoinRank] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        getCoinRank()
    }
    
    private func setupTableView() {
        
        /// 注册cell
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        /// 设置tableFooterView
        tableView.tableFooterView = UIView()
        
        /// 设置数据源与代理
        tableView.dataSource = self
        tableView.delegate = self
        
        /// 简单布局
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(self.view)
        }
    }

}

extension SwiftCoinRankListController {
    private func getCoinRank() {
        /// 这里只获取第一页的数据
        myProvider.request(MyService.coinRank(1)) { (result: Result<Response, MoyaError>)  in
            switch result {
                case .success(let response):
                    let data = response.data
                    guard let baseModel = try? JSONDecoder().decode(BaseModel<Page<CoinRank>>.self, from: data), let array = baseModel.data?.datas else {
                        return
                    }
                    self.dataSource = array
                    self.tableView.reloadData()
                    
                case .failure(let error):
                    print(error.errorDescription)
            }
        }
    }
}

extension SwiftCoinRankListController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let coinRank = dataSource[indexPath.row]
        
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
}

extension SwiftCoinRankListController: UITableViewDelegate {}
