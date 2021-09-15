//
//  RxFSPagerViewDelegateProxy.swift
//  RxStudy
//
//  Created by dy on 2021/9/14.
//  Copyright © 2021 season. All rights reserved.
//  将FSPagerViewDelegate做Rx封装,这种封装真的是类啊,而且容易出错,吃力不讨好,我也不想在封装第二个了,我放弃治疗了

import RxSwift
import RxCocoa
import FSPagerView

extension FSPagerView: HasDelegate {
    public typealias Delegate = FSPagerViewDelegate
}

open class RxFSPagerViewDelegateProxy
    : DelegateProxy<FSPagerView, FSPagerViewDelegate>
    , DelegateProxyType
    , FSPagerViewDelegate {
    
    /// Typed parent object.
    public weak private(set) var pagerView: FSPagerView?

    /// - parameter scrollView: Parent object for delegate proxy.
    public init(pagerView: ParentObject) {
        self.pagerView = pagerView
        super.init(parentObject: pagerView, delegateProxy: RxFSPagerViewDelegateProxy.self)
    }
    
    public static func registerKnownImplementations() {
        self.register { RxFSPagerViewDelegateProxy(pagerView: $0) }
    }
    
    private var _pagerViewShouldHighlightItemAtPublishSubject: PublishSubject<Int>?
    
    private var _pagerViewDidHighlightItemAtPublishSubject: PublishSubject<Int>?
    
    private var _pagerViewShouldSelectItemAtPublishSubject: PublishSubject<Int>?
    
    private var _pagerViewDidSelectItemAtPublishSubject: PublishSubject<Int>?
    
    private var _pagerViewWillDisplayPublishSubject: PublishSubject<(FSPagerViewCell, Int)>?
    
    private var _pagerViewDidEndDisplayingPublishSubject: PublishSubject<(FSPagerViewCell, Int)>?
    
    private var _pagerViewWillBeginDraggingPublishSubject: PublishSubject<()>?
    
    private var _pagerViewWillEndDraggingPublishSubject: PublishSubject<Int>?
    
    private var _pagerViewDidScrollPublishSubject: PublishSubject<()>?
    
    private var _pagerViewDidEndScrollAnimationPublishSubject: PublishSubject<()>?
    
    private var _pagerViewDidEndDeceleratingPublishSubject: PublishSubject<()>?


    /// Optimized version used for observing content offset changes.
    internal var pagerViewShouldHighlightItemAtPublishSubject: PublishSubject<Int> {
        
        if let subject = _pagerViewShouldHighlightItemAtPublishSubject {
            return subject
        }

        let subject = PublishSubject<Int>()
        _pagerViewShouldHighlightItemAtPublishSubject = subject
        
        return subject
    }
    
    internal var pagerViewDidHighlightItemAtPublishSubject: PublishSubject<Int> {
        
        if let subject = _pagerViewDidHighlightItemAtPublishSubject {
            return subject
        }

        let subject = PublishSubject<Int>()
        _pagerViewDidHighlightItemAtPublishSubject = subject
        
        return subject
    }
    
    internal var pagerViewShouldSelectItemAtPublishSubject: PublishSubject<Int> {
        
        if let subject = _pagerViewShouldSelectItemAtPublishSubject {
            return subject
        }

        let subject = PublishSubject<Int>()
        _pagerViewShouldSelectItemAtPublishSubject = subject
        
        return subject
    }
    
    internal var pagerViewDidSelectItemAtPublishSubject: PublishSubject<Int> {
        
        if let subject = _pagerViewDidSelectItemAtPublishSubject {
            return subject
        }

        let subject = PublishSubject<Int>()
        _pagerViewDidSelectItemAtPublishSubject = subject

        return subject
    }
    
    internal var pagerViewWillDisplayPublishSubject: PublishSubject<(FSPagerViewCell, Int)> {
        
        if let subject = _pagerViewWillDisplayPublishSubject {
            return subject
        }

        let subject = PublishSubject<(FSPagerViewCell, Int)>()
        _pagerViewWillDisplayPublishSubject = subject

        return subject
    }
    
    internal var pagerViewDidEndDisplayingPublishSubject: PublishSubject<(FSPagerViewCell, Int)> {
        
        if let subject = _pagerViewDidEndDisplayingPublishSubject {
            return subject
        }

        let subject = PublishSubject<(FSPagerViewCell, Int)>()
        _pagerViewDidEndDisplayingPublishSubject = subject

        return subject
    }
    
    internal var pagerViewWillBeginDraggingPublishSubject: PublishSubject<()> {
        if let subject = _pagerViewWillBeginDraggingPublishSubject {
            return subject
        }

        let subject = PublishSubject<()>()
        _pagerViewWillBeginDraggingPublishSubject = subject

        return subject
    }
    
    internal var pagerViewWillEndDraggingPublishSubject: PublishSubject<Int> {
        if let subject = _pagerViewWillEndDraggingPublishSubject {
            return subject
        }

        let subject = PublishSubject<Int>()
        _pagerViewWillEndDraggingPublishSubject = subject

        return subject
    }
    
    internal var pagerViewDidScrollPublishSubject: PublishSubject<()> {
        if let subject = _pagerViewDidScrollPublishSubject {
            return subject
        }

        let subject = PublishSubject<()>()
        _pagerViewDidScrollPublishSubject = subject

        return subject
    }
    
    internal var pagerViewDidEndScrollAnimationPublishSubject: PublishSubject<()> {
        if let subject = _pagerViewDidEndScrollAnimationPublishSubject {
            return subject
        }

        let subject = PublishSubject<()>()
        _pagerViewDidEndScrollAnimationPublishSubject = subject

        return subject
    }
    
    internal var pagerViewDidEndDeceleratingPublishSubject: PublishSubject<()> {
        if let subject = _pagerViewDidEndDeceleratingPublishSubject {
            return subject
        }

        let subject = PublishSubject<()>()
        _pagerViewDidEndDeceleratingPublishSubject = subject

        return subject
    }
    
    // MARK: delegate methods
    
    public func pagerView(_ pagerView: FSPagerView, shouldHighlightItemAt index: Int) -> Bool {
        
        if let subject = _pagerViewShouldHighlightItemAtPublishSubject {
            subject.on(.next(index))
        }
        
        return self._forwardToDelegate?.pagerView?(pagerView, shouldHighlightItemAt: index) ?? true
    }
    
    public func pagerView(_ pagerView: FSPagerView, didHighlightItemAt index: Int) {
        
        if let subject = _pagerViewDidHighlightItemAtPublishSubject {
            subject.on(.next(index))
        }
        
        self._forwardToDelegate?.pagerView?(pagerView, didHighlightItemAt: index)
    }
    
    public func pagerView(_ pagerView: FSPagerView, shouldSelectItemAt index: Int) -> Bool {
        
        if let subject = _pagerViewShouldSelectItemAtPublishSubject {
            subject.on(.next(index))
        }
        
        return self._forwardToDelegate?.pagerView?(pagerView, shouldSelectItemAt: index) ?? true
    }
    
    public func pagerView(_ pagerView: FSPagerView, didSelectItemAt index: Int) {
        
        if let subject = _pagerViewDidSelectItemAtPublishSubject {
            subject.on(.next(index))
        }
        self._forwardToDelegate?.pagerView(pagerView, didSelectItemAt: index)
    }
    
    public func pagerView(_ pagerView: FSPagerView, willDisplay cell: FSPagerViewCell, forItemAt index: Int) {
        
        if let subject = _pagerViewWillDisplayPublishSubject {
            subject.on(.next((cell, index)))
        }
        self._forwardToDelegate?.pagerView(pagerView, willDisplay: cell, forItemAt: index)
    }
    
    public func pagerView(_ pagerView: FSPagerView, didEndDisplaying cell: FSPagerViewCell, forItemAt index: Int) {
        
        if let subject = _pagerViewDidEndDisplayingPublishSubject {
            subject.on(.next((cell, index)))
        }
        self._forwardToDelegate?.pagerView(pagerView, didEndDisplaying: cell, forItemAt: index)
    }
    
    public func pagerViewWillBeginDragging(_ pagerView: FSPagerView) {
        
        if let subject = _pagerViewWillBeginDraggingPublishSubject {
            subject.on(.next(()))
        }
        self._forwardToDelegate?.pagerViewWillBeginDragging?(pagerView)
    }
    
    public func pagerViewWillEndDragging(_ pagerView: FSPagerView, targetIndex: Int) {
        
        if let subject = _pagerViewWillEndDraggingPublishSubject {
            subject.on(.next(targetIndex))
        }
        self._forwardToDelegate?.pagerViewWillEndDragging?(pagerView, targetIndex: targetIndex)
    }
    
    public func pagerViewDidScroll(_ pagerView: FSPagerView) {

        if let subject = _pagerViewDidScrollPublishSubject {
            subject.on(.next(()))
        }
        self._forwardToDelegate?.pagerViewDidScroll?(pagerView)
    }
    
    public func pagerViewDidEndScrollAnimation(_ pagerView: FSPagerView) {
        
        if let subject = _pagerViewDidEndScrollAnimationPublishSubject {
            subject.on(.next(()))
        }
        self._forwardToDelegate?.pagerViewDidEndScrollAnimation?(pagerView)
    }
    
    public func pagerViewDidEndDecelerating(_ pagerView: FSPagerView) {
        if let subject = _pagerViewDidEndDeceleratingPublishSubject {
            subject.on(.next(()))
        }
        self._forwardToDelegate?.pagerViewDidEndDecelerating?(pagerView)
    }
    
    deinit {
        if let subject = _pagerViewShouldHighlightItemAtPublishSubject {
            subject.on(.completed)
        }
        
        if let subject = _pagerViewDidHighlightItemAtPublishSubject {
            subject.on(.completed)
        }
        
        if let subject = _pagerViewShouldSelectItemAtPublishSubject {
            subject.on(.completed)
        }
        
        if let subject = _pagerViewDidSelectItemAtPublishSubject {
            subject.on(.completed)
        }
        
        if let subject = _pagerViewWillDisplayPublishSubject {
            subject.on(.completed)
        }
        
        if let subject = _pagerViewDidEndDisplayingPublishSubject {
            subject.on(.completed)
        }
        
        if let subject = _pagerViewWillBeginDraggingPublishSubject {
            subject.on(.completed)
        }
        
        if let subject = _pagerViewWillEndDraggingPublishSubject {
            subject.on(.completed)
        }
        
        if let subject = _pagerViewDidScrollPublishSubject {
            subject.on(.completed)
        }

        if let subject = _pagerViewDidEndScrollAnimationPublishSubject {
            subject.on(.completed)
        }
        
        if let subject = _pagerViewDidEndDeceleratingPublishSubject {
            subject.on(.completed)
        }
    }
}
