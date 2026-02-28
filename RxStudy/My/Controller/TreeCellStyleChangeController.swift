//
//  TreeCellStyleChangeController.swift
//  RxStudy
//
//  Created by dy on 2025/5/20.
//  Copyright © 2025 season. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa

class TreeCellStyleChangeController: BaseTableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        binding()
    }
}

extension TreeCellStyleChangeController {
    private func setupUI() {
        title = "更换App图标"
        
        tableView.mj_header = nil
        tableView.mj_footer = nil
        
        tableView.emptyDataSetSource = nil
        tableView.emptyDataSetDelegate = nil
        
        tableView.rowHeight = 44
    }
    
    private func binding() {

        Driver.just(LayoutType.allCases)
            .drive(tableView.rx.items) { [weak self] (tableView, _, type) in
                let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.className)!
                cell.textLabel?.text = type.title
                return cell
            }
            .disposed(by: rx.disposeBag)
        
        /// 这里相当于重写
        tableView.rx.itemSelected
            .bind { [weak self] (indexPath) in
                self?.tableView.deselectRow(at: indexPath, animated: false)
                let type = LayoutType.allCases[indexPath.row]
                AccountManager.shared.layoutType = type
                NotificationCenter.default.post(name: .Layout.typeChange, object: type)
                self?.navigationController?.popViewController(animated: true)
            }
            .disposed(by: rx.disposeBag)
    }
}
