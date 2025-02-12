//
//  Notifications.swift
//  RxStudy
//
//  Created by dy on 2025/2/10.
//  Copyright © 2025 season. All rights reserved.
//

import Foundation

import RxSwift

/// 通过枚举完全封装通知事件
final class EventBus {
    
    private init() {}
    
    static func post<Event>(event: Event, center: NotificationCenter = NotificationCenter.default, object: AnyObject? = nil, userInfo: [AnyHashable: AnyObject]? = nil) where Event: RawRepresentable, Event.RawValue == String {
        center.post(name: NSNotification.Name(rawValue: event.rawValue), object: object, userInfo: userInfo)
    }

    static func rx<Event>(event: Event, center: NotificationCenter = NotificationCenter.default, object: AnyObject? = nil) -> Observable<Notification> where Event: RawRepresentable, Event.RawValue == String {
        return center.rx.notification(Notification.Name(rawValue: event.rawValue), object: object)
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

protocol Eventable: RawRepresentable where RawValue == String {
    func post(center: NotificationCenter, object: AnyObject?, userInfo: [AnyHashable: AnyObject]?)

    func rx(center: NotificationCenter, object: AnyObject?) -> Observable<Notification>
    
    func post(object: AnyObject?, userInfo: [AnyHashable: AnyObject]?)

    func rx(object: AnyObject?) -> Observable<Notification>
}

extension Eventable {
    func post(center: NotificationCenter = NotificationCenter.default, object: AnyObject? = nil, userInfo: [AnyHashable: AnyObject]? = nil) {
        center.post(name: NSNotification.Name(rawValue: rawValue), object: object, userInfo: userInfo)
    }
    
    func rx(center: NotificationCenter = NotificationCenter.default, object: AnyObject? = nil) -> Observable<Notification> {
        return center.rx.notification(Notification.Name(rawValue: rawValue), object: object)
    }
    
    func post(object: AnyObject?, userInfo: [AnyHashable: AnyObject]?) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: rawValue), object: object, userInfo: userInfo)
    }

    func rx(object: AnyObject?) -> Observable<Notification> {
        return NotificationCenter.default.rx.notification(Notification.Name(rawValue: rawValue), object: object)
    }
}
    
