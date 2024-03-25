//
//  EditTableViewController.swift
//  RxStudy
//
//  Created by dy on 2021/9/11.
//  Copyright © 2021 season. All rights reserved.
//

import Foundation

// 定义各种操作命令
enum TableEditingCommand {
    case setItems(items: [String])  // 设置表格数据
    case addItem(item: String)  // 新增数据
    case moveItem(from: IndexPath, to: IndexPath) // 移动数据
    case deleteItem(IndexPath) // 删除数据
}

// 定义表格对应的ViewModel
struct TableViewModel {
    // 表格数据项
    fileprivate var items: [String]
      
    init(items: [String] = []) {
        self.items = items
    }
      
    // 执行相应的命令，并返回最终的结果
    func execute(command: TableEditingCommand) -> TableViewModel {
        switch command {
        case .setItems(let items):
            print("设置表格数据。")
            return TableViewModel(items: items)
        case .addItem(let item):
            print("新增数据项。")
            var items = self.items
            items.append(item)
            return TableViewModel(items: items)
        case .moveItem(let from, let to):
            print("移动数据项。")
            var items = self.items
            items.insert(items.remove(at: from.row), at: to.row)
            return TableViewModel(items: items)
        case .deleteItem(let indexPath):
            print("删除数据项。")
            var items = self.items
            items.remove(at: indexPath.row)
            return TableViewModel(items: items)
        }
    }
}

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
 
class EditTableViewController: UIViewController {
     
    // 刷新按钮
    lazy var refreshButton = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: nil)
     
    // 新增按钮
    lazy var addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: nil)
     
    // 表格
    lazy var tableView = UITableView(frame: self.view.frame, style: .plain)
     
    let disposeBag = DisposeBag()
     
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItems = [addButton, refreshButton]
         
        // 创建一个重用的单元格
        tableView.register(UITableViewCell.self,
                                 forCellReuseIdentifier: "Cell")
        view.addSubview(self.tableView)
         
        // 表格模型
        let initialVM = TableViewModel()
         
        // 刷新数据命令
        let refreshCommand = refreshButton.rx.tap.asObservable()
            .startWith(()) // 加这个为了页面初始化时会自动加载一次数据
            .flatMapLatest(getRandomResult)
            .map(TableEditingCommand.setItems)
         
        // 新增条目命令
        let addCommand = addButton.rx.tap.asObservable()
            .map { "\(arc4random())" }
            .map(TableEditingCommand.addItem)
         
        // 移动位置命令
        let movedCommand = tableView.rx.itemMoved
            .map(TableEditingCommand.moveItem)
         
        // 删除条目命令
        let deleteCommand = tableView.rx.itemDeleted.asObservable()
            .map(TableEditingCommand.deleteItem)
         
        // 绑定单元格数据
        Observable.of(refreshCommand, addCommand, movedCommand, deleteCommand)
            .merge()
            .scan(initialVM) { (vm: TableViewModel, command: TableEditingCommand)
                -> TableViewModel in
                return vm.execute(command: command)
            }
            .startWith(initialVM)
            .map {
                [AnimatableSectionModel(model: "", items: $0.items)]
            }
            .share(replay: 1)
            .bind(to: tableView.rx.items(dataSource: EditTableViewController.dataSource()))
            .disposed(by: disposeBag)
    }
     
    // 获取随机数据
    func getRandomResult() -> Observable<[String]> {
        print("生成随机数据。")
        let items = (0 ..< 5).map {_ in
            "\(arc4random())"
        }
        return Observable.just(items)
    }
}
 
extension EditTableViewController {
    // 创建表格数据源
    static func dataSource() -> RxTableViewSectionedAnimatedDataSource
        <AnimatableSectionModel<String, String>> {
        return RxTableViewSectionedAnimatedDataSource(
            // 设置插入、删除、移动单元格的动画效果
            animationConfiguration: AnimationConfiguration(insertAnimation: .top,
                                                           reloadAnimation: .fade,
                                                           deleteAnimation: .left),
            configureCell: {
                (_, tv, indexPath, element) in
                let cell = tv.dequeueReusableCell(withIdentifier: "Cell")!
                cell.textLabel?.text = "条目\(indexPath.row)：\(element)"
                return cell
        },
            canEditRowAtIndexPath: { _, _ in
                return true // 单元格可删除
        },
            canMoveRowAtIndexPath: { _, _ in
                return true // 单元格可移动
        }
        )
    }
}
