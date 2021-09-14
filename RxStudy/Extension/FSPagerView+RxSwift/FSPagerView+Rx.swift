//
//  FSPagerView+Rx.swift
//  RxStudy
//
//  Created by dy on 2021/9/14.
//  Copyright © 2021 season. All rights reserved.
//

import RxSwift
import RxCocoa
import FSPagerView

extension Reactive where Base: FSPagerView {
     
    /// 代理委托
    public var delegate: DelegateProxy<FSPagerView, FSPagerViewDelegate> {
        return RxFSPagerViewDelegateProxy.proxy(for: base)
    }
    
    public var shouldHighlightItemAtIndex: Observable<Int> {
        return delegate
            .methodInvoked(#selector(FSPagerViewDelegate
                .pagerView(_:shouldHighlightItemAt:)))
            .map({ (a) in
                return try castOrThrow(Int.self, a[1])
            })
    }
}

//转类型的函数（转换失败后，会发出Error）
fileprivate func castOrThrow<T>(_ resultType: T.Type, _ object: Any) throws -> T {
    guard let returnValue = object as? T else {
        throw RxCocoaError.castingError(object: object, targetType: resultType)
    }
    return returnValue
}
