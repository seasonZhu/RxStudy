//
//  ThirdPartyController.swift
//  RxStudy
//
//  Created by season on 2021/6/21.
//  Copyright © 2021 season. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import AcknowList

class ThirdPartyController: BaseTableViewController {
    
    let dataSource: BehaviorRelay<[Acknow]> = BehaviorRelay(value: [])

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        title = AcknowLocalization.localizedTitle()
        
        tableView.mj_header = nil
        tableView.mj_footer = nil
        
        tableView.emptyDataSetSource = nil
        tableView.emptyDataSetDelegate = nil
        
        tableView.rowHeight = 44
        
        let list = AcknowParser(plistPath: defaultAcknowledgementsPlistPath()!).parseAcknowledgements()
        
        dataSource.accept(list)
                
        /// 获取indexPath
        tableView.rx.itemSelected
            .bind { [weak self] (indexPath) in
                self?.tableView.deselectRow(at: indexPath, animated: false)
                print(indexPath)
            }
            .disposed(by: rx.disposeBag)
        
        
        /// 获取cell中的模型
        tableView.rx.modelSelected(Acknow.self)
            .subscribe(onNext: { [weak self] model in
                guard let self = self else { return }
                self.navigationController?.pushViewController(ThirdPartyDetailController(acknowledgement: model), animated: true)
            })
            .disposed(by: rx.disposeBag)
        
        dataSource
            .asDriver(onErrorJustReturn: [])
            .drive(tableView.rx.items) { (tableView, row, info) in
                if let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.className) {
                    cell.textLabel?.text = info.title
                    return cell
                }else {
                    let cell = UITableViewCell(style: .subtitle, reuseIdentifier: UITableViewCell.className)
                    cell.textLabel?.text = info.title
                    return cell
                }
            }
            .disposed(by: rx.disposeBag)
    }
}

extension ThirdPartyController {
    private func defaultAcknowledgementsPlistPath() -> String? {
        guard let bundleName = bundleName() else {
            return nil
        }

        let plistName = "Pods-\(bundleName)-acknowledgements"

        guard let plistPath = acknowledgementsPlistPath(name: plistName),
            FileManager.default.fileExists(atPath: plistPath) else {
            return nil
        }

        return plistPath
    }
    
    private func bundleName() -> String? {
        let infoDictionary = Bundle.main.infoDictionary

        if let cfBundleName = infoDictionary?["CFBundleName"] as? String {
            return cfBundleName
        }
        else if let cfBundleExecutable = infoDictionary?["CFBundleExecutable"] as? String {
            return cfBundleExecutable
        }
        else {
            return nil
        }
    }
    
    private func acknowledgementsPlistPath(name:String) -> String? {
        return Bundle.main.path(forResource: name, ofType: "plist")
    }
}


