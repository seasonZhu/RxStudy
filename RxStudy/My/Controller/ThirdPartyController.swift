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

/// 没有直接使用AcknowList自带的控制器,是因为其导航栏的风格和App的不同,所以自己写了
class ThirdPartyController: BaseTableViewController {

    // AcknowList library removed - temporarily use empty data source
    // let dataSource = BehaviorRelay<[Acknow]>(value: [])

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        binding()
    }
}

extension ThirdPartyController {
    private func setupUI() {
        // title = AcknowLocalization.localizedTitle() // AcknowList 库已移除
        title = "第三方库" // 设置固定标题

        tableView.mj_header = nil
        tableView.mj_footer = nil

        tableView.emptyDataSetSource = nil
        tableView.emptyDataSetDelegate = nil

        tableView.rowHeight = 44

    }

    private func binding() {
        // AcknowList library removed - temporarily commented
        // let list = AcknowParser.defaultAcknowList()?.acknowledgements ?? []
        //
        // dataSource.accept(list)
        //
        // /// 获取cell中的模型
        // tableView.rx.modelSelected(Acknow.self)
        //     .map { (ThirdPartyDetailController(acknowledgement: $0), true) }
        //     .bind(onNext: navigationController!.pushViewController)
        //     .disposed(by: rx.disposeBag)
        //
        // dataSource
        //     .asDriver(onErrorJustReturn: [])
        //     .drive(tableView.rx.items) { (tableView, _, info) in
        //
        //         let cell = tableView.dequeueReusableCell(withIdentifier: UITableViewCell.className)!
        //         cell.textLabel?.text = info.title
        //         return cell
        //     }
        //     .disposed(by: rx.disposeBag)
    }

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
        } else if let cfBundleExecutable = infoDictionary?["CFBundleExecutable"] as? String {
            return cfBundleExecutable
        } else {
            return nil
        }
    }

    private func acknowledgementsPlistPath(name: String) -> String? {
        return Bundle.main.path(forResource: name, ofType: "plist")
    }
}
