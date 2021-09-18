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

/**
 这个FSPagerViewDelegate有毒,它的代理分为objc书写方式和swift书写方式,在这里调用的使用其实调用的oc的书写方式,然后找不到方法名,然后就崩溃了.我要换个代理写
 */

extension Reactive where Base: FSPagerView {
     
    /// 代理委托
    public var delegate: DelegateProxy<FSPagerView, FSPagerViewDelegate> {
        return RxFSPagerViewDelegateProxy.proxy(for: base)
    }
    
    public var shouldHighlightItemAtIndex: Observable<Int> {
        return delegate
            .sentMessage(#selector(FSPagerViewDelegate
                .pagerView(_:shouldHighlightItemAt:)))
            .map({ (a) in
                return try castOrThrow(Int.self, a[1])
            })
    }
    
    public var didHighlightItemAtIndex: Observable<Int> {
        return delegate
            .sentMessage(#selector(FSPagerViewDelegate
                .pagerView(_:didHighlightItemAt:)))
            .map({ (a) in
                return try castOrThrow(Int.self, a[1])
            })
    }
    
    public var shouldSelectItemAtIndex: Observable<Int> {
        return delegate
            .sentMessage(#selector(FSPagerViewDelegate
                .pagerView(_:shouldSelectItemAt:)))
            .map({ (a) in
                return try castOrThrow(Int.self, a[1])
            })
    }
    
    public var didSelectItemAtIndex: Observable<Int> {
        return delegate
            .sentMessage(#selector(FSPagerViewDelegate
                .pagerView(_:didSelectItemAt:)))
            .map({ (a) in
                return try castOrThrow(Int.self, a[1])
            })
    }
    
    public var willDisplayCell: Observable<(cell: FSPagerViewCell, index: Int)> {
        return delegate
            .sentMessage(#selector(FSPagerViewDelegate.pagerView(_:willDisplay:forItemAt:)))
            .map({ (a) in
                let cell = try castOrThrow(FSPagerViewCell.self, a[1])
                let index = try castOrThrow(Int.self, a[2])
                return (cell: cell, index: index)
            })
    }
    
    public var didEndDisplayingCell: Observable<(cell: FSPagerViewCell, index: Int)> {
        return delegate
            .sentMessage(#selector(FSPagerViewDelegate.pagerView(_:didEndDisplaying:forItemAt:)))
            .map({ (a) in
                let cell = try castOrThrow(FSPagerViewCell.self, a[1])
                let index = try castOrThrow(Int.self, a[2])
                return (cell: cell, index: index)
            })
    }
    
    public var pagerViewWillBeginDragging: Observable<()> {
        return delegate
            .sentMessage(#selector(FSPagerViewDelegate.pagerViewWillBeginDragging(_:)))
            .map({ (a) in
                return ()
            })
    }
    
    public var pagerViewWillEndDragging: Observable<Int> {
        return delegate
            .sentMessage(#selector(FSPagerViewDelegate
                .pagerViewWillEndDragging(_:targetIndex:)))
            .map({ (a) in
                return try castOrThrow(Int.self, a[1])
            })
    }
    
    public var pagerViewDidScroll: Observable<()> {
        return delegate
            .sentMessage(#selector(FSPagerViewDelegate.pagerViewDidScroll(_:)))
            .map({ (a) in
                return ()
            })
    }
    
    public var pagerViewDidEndScrollAnimation: Observable<()> {
        return delegate
            .sentMessage(#selector(FSPagerViewDelegate.pagerViewDidEndScrollAnimation(_:)))
            .map({ (a) in
                return ()
            })
    }
    
    public var pagerViewDidEndDecelerating: Observable<()> {
        return delegate
            .sentMessage(#selector(FSPagerViewDelegate.pagerViewDidEndDecelerating(_:)))
            .map({ (a) in
                return ()
            })
    }
    
    public func setDelegate(_ delegate: FSPagerViewDelegate)
        -> Disposable {
        return RxFSPagerViewDelegateProxy.installForwardDelegate(delegate, retainDelegate: false, onProxyForObject: self.base)
    }
}

//转类型的函数（转换失败后，会发出Error）
fileprivate func castOrThrow<T>(_ resultType: T.Type, _ object: Any) throws -> T {
    guard let returnValue = object as? T else {
        throw RxCocoaError.castingError(object: object, targetType: resultType)
    }
    return returnValue
}

fileprivate func castOptionalOrThrow<T>(_ resultType: T.Type,
                                        _ object: Any) throws -> T? {
    if NSNull().isEqual(object) {
        return nil
    }
     
    guard let returnValue = object as? T else {
        throw RxCocoaError.castingError(object: object, targetType: resultType)
    }
     
    return returnValue
}
