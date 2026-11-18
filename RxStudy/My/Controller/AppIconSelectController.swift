//
//  AppIconSelectController.swift
//  RxStudy
//
//  Created by dy on 2025/2/7.
//  Copyright © 2025 season. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import MJRefresh

class AppIconSelectController: BaseTableViewController {
    
    private var isChangingIcon = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        binding()
    }
}

extension AppIconSelectController {
    private func setupUI() {
        title = "更换App图标"
        
        tableView.mj_header = nil
        tableView.mj_footer = nil
        
        tableView.emptyDataSetSource = nil
        tableView.emptyDataSetDelegate = nil
        
        tableView.rowHeight = 44
    }
    
    private func binding() {

        Driver.just(AppIconType.allCases)
            .drive(tableView.rx.items) { (tableView, _, type) in
                let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.className)!
                cell.textLabel?.text = type.title
                return cell
            }
            .disposed(by: rx.disposeBag)
        
        tableView.rx.itemSelected
            .bind { [weak self] indexPath in
                guard let self else { return }
                self.tableView.deselectRow(at: indexPath, animated: false)
                self.changeIcon(to: AppIconType.allCases[indexPath.row])
            }
            .disposed(by: rx.disposeBag)
    }

    private func changeIcon(to type: AppIconType) {
        guard !isChangingIcon else { return }

        let application = UIApplication.shared
        guard application.supportsAlternateIcons else {
            print("不支持设置其他图标")
            return
        }

        guard application.alternateIconName != type.iconName else {
            showIconAlert(message: "当前使用的正是这个图标，无需重复设置")
            return
        }

        isChangingIcon = true
        application.setAlternateIconName(type.iconName) { [weak self] error in
            DispatchQueue.main.async {
                self?.isChangingIcon = false
                guard let error else { return }

                print("设置 App 图标失败：\(error)")
                guard let self, self.viewIfLoaded?.window != nil,
                      self.navigationController?.visibleViewController === self,
                      self.presentedViewController == nil else { return }

                self.showIconAlert(message: "更换 App 图标失败，请重试")
            }
        }
    }

    private func showIconAlert(message: String) {
        let alert = UIAlertController(title: "提示", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
