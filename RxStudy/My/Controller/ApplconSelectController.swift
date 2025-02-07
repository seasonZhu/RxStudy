//
//  ApplconSelectController.swift
//  RxStudy
//
//  Created by dy on 2025/2/7.
//  Copyright © 2025 season. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import MJRefresh

class ApplconSelectController: BaseTableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        binding()
    }
}

extension ApplconSelectController {
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
                
                guard UIApplication.shared.supportsAlternateIcons else {
                    print("不支持设置其他图标")
                    return
                }
                
                let type = AppIconType.allCases[indexPath.row]
                
                guard UIApplication.shared.alternateIconName != type.iconName else {
                    let alert = UIAlertController(title: "提示", message: "当前使用的正是这个图标，无需重复设置", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    self?.present(alert, animated: true)
                    return
                }
                
                switch type {
                case .onBackgroundTimer:
                    break
                default:
                    UIApplication.shared.setAlternateIconName(type.iconName) { error in
                        if let error {
                            print("设置 App Icon 出错： \(error)")
                        } else {
                            print("App Icon 设置成功")
                        }
                    }
                }

            }
            .disposed(by: rx.disposeBag)
    }
}
