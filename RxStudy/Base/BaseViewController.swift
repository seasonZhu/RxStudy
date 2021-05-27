//
//  BaseViewController.swift
//  RxStudy
//
//  Created by season on 2021/5/21.
//  Copyright © 2021 season. All rights reserved.
//

import UIKit

import RxSwift

class BaseViewController: UIViewController {

    let disposeBag = DisposeBag()
    
    deinit {
        print("\(className)被销毁了")
    }

}

extension BaseViewController {
    func pushToWebViewController(webLoadInfo: WebLoadInfo, isFromBanner: Bool = false) {
        let vc = WebViewController(webLoadInfo: webLoadInfo, isFromBanner: isFromBanner)
        navigationController?.pushViewController(vc, animated: true)
    }
}
