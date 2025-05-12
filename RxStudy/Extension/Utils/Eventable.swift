//
//  Notifications.swift
//  RxStudy
//
//  Created by dy on 2025/2/10.
//  Copyright © 2025 season. All rights reserved.
//

import Foundation

import RxSwift

protocol Eventable: RawRepresentable where RawValue == String {
    
    func post(object: AnyObject?, userInfo: [AnyHashable: AnyObject]?)

    func rx(object: AnyObject?) -> Observable<Notification>
    
    var rx: Observable<Notification> { get }
}

extension Eventable {
    
    func post(object: AnyObject? = nil, userInfo: [AnyHashable: AnyObject]? = nil) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: rawValue), object: object, userInfo: userInfo)
    }
    
    func rx(object: AnyObject? = nil) -> Observable<Notification> {
        return NotificationCenter.default.rx.notification(Notification.Name(rawValue: rawValue), object: object)
    }
    
    var rx: Observable<Notification> {
        return NotificationCenter.default.rx.notification(Notification.Name(rawValue: rawValue))
    }
}

/// 这里其实是可以封装NotificationCenter.default.addObserver方法的,但是因为这个方法需要对应的NotificationCenter.default.removeObserver方法,所以这里就不推荐了
private extension Eventable {
    func addObserver(object obj: Any?, queue: OperationQueue?, using block: @escaping @Sendable (Notification) -> Void) -> NSObjectProtocol {
        return NotificationCenter.default.addObserver(forName: Notification.Name(rawValue: rawValue), object: obj, queue: queue, using: block)
    }

    func removeObserver(_ observer: Any, object anObject: Any? = nil) {
        return NotificationCenter.default.removeObserver(observer, name: NSNotification.Name(rawValue), object: anObject)
    }
}

/// 这里的通知只是一些简单的例子
enum EventType: String {
    case setEventView
    case addEvent
    case openOperatorDescription
    case hideHelpWindow
}

extension EventType: Eventable {}
