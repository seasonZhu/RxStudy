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
    
    private var pageNum = 1
    
    private var isFinish = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        refresh()
    }
    
    private func setupTableView() {
        
        /// 注册cell
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: UITableViewCell.className)
        
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
    private func refresh() {
        pageNum = 1
        getCoinRank(pageNum: pageNum)
    }
    
    private func loadMore() {
        pageNum = pageNum + 1
        getCoinRank(pageNum: pageNum)
    }
    
    private func getCoinRank(pageNum: Int) {
        /// 这里只获取第一页的数据
        myProvider.request(MyService.coinRank(pageNum)) { (result: Result<Response, MoyaError>)  in
            switch result {
                case .success(let response):
                    
                    /// 最初的写法
                    let data = response.data
                    guard let baseModel = try? JSONDecoder().decode(BaseModel<Page<CoinRank>>.self, from: data), let array = baseModel.data?.datas else {
                        return
                    }
                    pageNum == 1 ? self.dataSource = array : self.dataSource.append(contentsOf: array)
                    self.tableView.reloadData()
                    
                    if #available(iOS 11,*) {
                        /*
                         iOS11之后reloadData方法会执行
                         - (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath 方法，将当前所有的cell过一遍，而iOS11之前只是将展示的cell过一遍。故加此方法使其在过第一次的时候不执行加载更多数
                         */
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            self.isFinish = true
                        }
                    }else {
                        self.isFinish = true
                    }
                    
                    return
                    
                    /// Response扩展中已经有的写法
                    guard let model = try? response.map(BaseModel<Page<CoinRank>>.self), let list = model.data?.datas else {
                        return
                    }
                    self.dataSource = list
                    self.tableView.reloadData()
                    
                case .failure(let error):
                    self.isFinish = false
                    print(error.errorDescription)
            }
            
            let newResult: Result<BaseModel<Page<CoinRank>>, MoyaError> = result.map()
            print(newResult)
            
            let otherResult = result.map(BaseModel<Page<CoinRank>>.self)
            print(otherResult)
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
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.className) {
            cell.textLabel?.text = coinRank.username
            cell.detailTextLabel?.text = coinRank.coinCount?.toString
            return cell
        }else {
            let cell = UITableViewCell(style: .subtitle, reuseIdentifier: UITableViewCell.className)
            cell.textLabel?.text = coinRank.username
            cell.detailTextLabel?.text = coinRank.coinCount?.toString
            return cell
        }
    }
}

/// RxSwift框架下,一般的Cocoa的侧滑删除不起作用,在这里正常
extension SwiftCoinRankListController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let row = indexPath.row
        let distance = dataSource.count - 25
        print("row: \(row), distance:\(distance)  ")
        if row == distance && isFinish {
            loadMore()
        }
    }
    
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

/// 自己写的,对Result的扩展写法
extension Result where Success == Moya.Response, Failure == MoyaError {
    public func map<Model: Codable>() -> Result<Model, Failure> {
        switch self {
            case .success(let response):
                do {
                    let model = try JSONDecoder().decode(Model.self, from: response.data)
                    return .success(model)
                } catch  {
                    let error = MoyaError.objectMapping(error, response)
                    return .failure(error)
                }
                
            case .failure(let error):
                return .failure(error)
        }
    }
    
    public func map<D: Decodable>(_ type: D.Type) -> Result<D, MoyaError> {
        switch self {
            case .success(let response):
                do {
                    let model = try JSONDecoder().decode(D.self, from: response.data)
                    return .success(model)
                } catch  {
                    let error = MoyaError.objectMapping(error, response)
                    return .failure(error)
                }
                
            case .failure(let error):
                return .failure(error)
        }
    }
}
