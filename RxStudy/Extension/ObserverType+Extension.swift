//
//  ObserverType+Extension.swift
//  RxStudy
//
//  Created by dy on 2022/10/21.
//  Copyright © 2022 season. All rights reserved.
//

import RxSwift

extension ObserverType where Element == Void {
    public func onNext() {
        on(.next(()))
    }
}
