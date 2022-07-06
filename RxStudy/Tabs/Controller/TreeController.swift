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
        
        //tableView.mj_header = nil
        tableView.mj_footer = nil
            
        /// 获取cell中的模型
        tableView.rx.modelSelected(Tab.self)
            .subscribe(onNext: { [weak self] tab in
                guard let self = self else { return }
                let vc = SingleTabListController(type: self.type, tab: tab)
                self.navigationController?.pushViewController(vc, animated: true)
            })
            .disposed(by: rx.disposeBag)
                
        let viewModel = TreeViewModel(type: type)
        
        tableView.mj_header?.rx.refresh
            .bind(onNext: viewModel.inputs.loadData)
            .disposed(by: rx.disposeBag)

        /// 绑定数据
        viewModel.outputs.dataSource
            .asDriver(onErrorJustReturn: [])
            .drive(rx.tableViewSectionAndCellConfig)
            .disposed(by: rx.disposeBag)
        
        /// 下拉与上拉状态绑定到tableView
        viewModel.outputs.refreshSubject?
            .bind(to: tableView.rx.refreshAction)
            .disposed(by: rx.disposeBag)
        
        /// 重写
        emptyDataSetButtonTap.subscribe { _ in
            viewModel.inputs.loadData()
        }.disposed(by: rx.disposeBag)
        
        viewModel.outputs.networkError
            .bind(to: rx.networkError)
            .disposed(by: rx.disposeBag)
        
        errorRetry
            .bind(onNext: viewModel.inputs.loadData)
            .disposed(by: rx.disposeBag)
    }
    
    fileprivate func tableViewSectionAndCellConfig(tabs: [Tab]) {
        guard tabs.isNotEmpty else {
            return
        }
        
        /// 这种带有section的tableView,不能通过一级菜单确定是否有数据,需要将二维数组进行降维打击
        let children = tabs.map { $0.children }.compactMap { $0 }
        let deepChildren = children.flatMap{ $0 }.map { $0.children }.compactMap { $0 }.flatMap { $0 }
        Observable.just(deepChildren).map { $0.isEmpty }
            .bind(to: isEmptyRelay)
            .disposed(by: rx.disposeBag)
        
        let sectionModels = tabs.map { tab in
            return SectionModel(model: tab, items: tab.children ?? [])
        }

        let items = Observable.just(sectionModels)
        
        /// 必须要加这一行,否则再次下拉刷新就崩溃,崩溃如下,后面想想如何优化
        /// Assertion failed: This is a feature to warn you that there is already a delegate (or data source) set somewhere previously. The action you are trying to perform will clear that delegate (data source) and that means that some of your features that depend on that delegate (data source) being set will likely stop working.
        /// If you are ok with this, try to set delegate (data source) to `nil` in front of this operation.
        tableView.dataSource = nil

        let dataSource = RxTableViewSectionedReloadDataSource<SectionModel<Tab, Tab>>(
            configureCell: { (ds, tv, indexPath, element) in
                
                let cell = tv.dequeueReusableCell(withIdentifier: UITableViewCell.className)!
                cell.textLabel?.text = ds.sectionModels[indexPath.section].model.children?[indexPath.row].name
                cell.textLabel?.font = UIFont.systemFont(ofSize: 15)
                cell.accessoryType = .disclosureIndicator
                return cell
            
        },
            titleForHeaderInSection: { ds, index in
                return ds.sectionModels[index].model.name
        })

        //绑定单元格数据
        items.bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: rx.disposeBag)
    }
}

extension Reactive where Base == TreeController {
    var tableViewSectionAndCellConfig: Binder<[Tab]> {
        return Binder(base) { base, tabs in
            base.tableViewSectionAndCellConfig(tabs: tabs)
        }
    }
}
