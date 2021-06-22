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

/// RxSwift框架下,一般的Cocoa的侧滑删除不起作用,在这里正常
extension SwiftCoinRankListController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return UITableViewCell.EditingStyle.delete
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "点击删除"
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == UITableViewCell.EditingStyle.delete {

        }
    }
}
