//
//  TreeController.swift
//  RxStudy
//
//  Created by season on 2021/5/27.
//  Copyright © 2021 season. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import NSObject_Rx
import RxDataSources
import SnapKit

/// 使用tableView配合section即可完成需求
class TreeController: BaseTableViewController {
    
    private let type: TagType
    
    init(type: TagType) {
        self.type = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
}

extension TreeController {
    private func setupUI() {
        title = type.title
        
        tableView.mj_header = nil
        tableView.mj_footer = nil
                
        /// 获取indexPath
        tableView.rx.itemSelected
            .bind { [weak self] (indexPath) in
                self?.tableView.deselectRow(at: indexPath, animated: false)
                print(indexPath)
            }
            .disposed(by: rx.disposeBag)
        
        
        /// 获取cell中的模型
        tableView.rx.modelSelected(Tab.self)
            .subscribe(onNext: { [weak self] tab in
                guard let self = self else { return }
                let vc = SingleTabListController(type: self.type, tab: tab)
                self.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: rx.disposeBag)
                
        let viewModel = TreeViewModel(type: type, disposeBag: rx.disposeBag)

        viewModel.inputs.loadData()

        /// 绑定数据
        viewModel.outputs.dataSource
            .subscribe(onNext: { [weak self] tabs in
                self?.tableViewSectionAndCellConfig(tabs: tabs)
            })
            .disposed(by: rx.disposeBag)
        
        /// 重写
        emptyDataSetButtonTap.subscribe { _ in
            viewModel.inputs.loadData()
        }.disposed(by: rx.disposeBag)
    }
    
    private func tableViewSectionAndCellConfig(tabs: [Tab]) {
        guard tabs.count > 0 else {
            return
        }
        
        /// 这种带有section的tableView,不能通过一级菜单确定是否有数据,需要将二维数组进行降维打击
        let children = tabs.map { $0.children }.compactMap { $0 }
        let deepChildren = children.flatMap{ $0 }.map { $0.children }.compactMap { $0 }.flatMap { $0 }
        Observable.just(deepChildren).map { $0.count == 0 }.bind(to: isEmpty).disposed(by: rx.disposeBag)
        
        let sectionModels = tabs.map { tab in
            return SectionModel(model: tab, items: tab.children ?? [])
        }

        let items = Observable.just(sectionModels)

        let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<Tab, Tab>>(configureCell: { (ds, tv, indexPath, element) in
            
            if let cell = tv.dequeueReusableCell(withIdentifier: "Cell") {
                cell.textLabel?.text = ds.sectionModels[indexPath.section].model.children?[indexPath.row].name
                cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
                cell.accessoryType = .disclosureIndicator
                return cell
            }else {
                let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
                cell.textLabel?.text = ds.sectionModels[indexPath.section].model.children?[indexPath.row].name
                cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
                cell.accessoryType = .disclosureIndicator
                return cell
            }
            
        })

        //设置分区头标题
        dataSource.titleForHeaderInSection = { ds, index in
            return ds.sectionModels[index].model.name
        }

        //绑定单元格数据
        items.bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: rx.disposeBag)
    }
}
