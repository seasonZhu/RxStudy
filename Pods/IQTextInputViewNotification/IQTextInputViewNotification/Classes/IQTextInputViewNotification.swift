//
//  IQTextInputViewNotification.swift
//  https://github.com/hackiftekhar/IQTextInputViewNotification
//  Copyright (c) 2013-24 Iftekhar Qurashi.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import UIKit
import Combine
public import IQKeyboardCore

@available(iOSApplicationExtension, unavailable)
@MainActor
@objcMembers public final class IQTextInputViewNotification: NSObject {

    private var storage: Set<AnyCancellable> = []

    private var textInputViewObservers: [AnyHashable: TextInputViewCompletion] = [:]

    private var findInteractionTextInputViewInfo: IQTextInputViewInfo?

    public private(set) var textInputViewInfo: IQTextInputViewInfo?

    public var event: IQTextInputViewInfo.Event? {
        textInputViewInfo?.event
    }

    public var textInputView: (any IQTextInputView)? {
        return textInputViewInfo?.textInputView
    }

    public override init() {
        super.init()

        //  Registering for TextInputView notification.
        do {
            let beginEditingNotificationNames: [Notification.Name] = [
                UITextField.textDidBeginEditingNotification,
                UITextView.textDidBeginEditingNotification
            ]

            for notificationName in beginEditingNotificationNames {
                NotificationCenter.default.publisher(for: notificationName)
                    .compactMap({ IQTextInputViewInfo(notification: $0, event: .beginEditing) })
                    .sink(receiveValue: { [weak self] info in
                        guard let self = self else { return }
                        self.didBeginEditing(info: info)
                    })
                    .store(in: &storage)
            }
        }

        do {
            let endEditingNotificationNames: [Notification.Name] = [
                UITextField.textDidEndEditingNotification,
                UITextView.textDidEndEditingNotification
            ]

            for notificationName in endEditingNotificationNames {
                NotificationCenter.default.publisher(for: notificationName)
                    .compactMap({ IQTextInputViewInfo(notification: $0, event: .endEditing) })
                    .sink(receiveValue: { [weak self] info in
                        guard let self = self else { return }
                        self.didEndEditing(info: info)
                    })
                    .store(in: &storage)
            }
        }
    }

    private func didBeginEditing(info: IQTextInputViewInfo) {

#if compiler(>=5.7)    // Xcode 14
        if #available(iOS 16.0, *),
           let findInteractionTextInputViewInfo = findInteractionTextInputViewInfo,
           findInteractionTextInputViewInfo.textInputView.iqFindInteraction?.isFindNavigatorVisible == true {
            // // This means the this didBeginEditing call comes due to find interaction
            textInputViewInfo = findInteractionTextInputViewInfo
            sendEvent(info: findInteractionTextInputViewInfo)
        } else if textInputViewInfo != info {
            textInputViewInfo = info
            findInteractionTextInputViewInfo = nil
            sendEvent(info: info)
        } else {
            findInteractionTextInputViewInfo = nil
        }
#else
        if textInputViewInfo != info {
            textInputViewInfo = info
            findInteractionTextInputViewInfo = nil
            sendEvent(info: info)
        } else {
            findInteractionTextInputViewInfo = nil
        }
#endif
    }

    private func didEndEditing(info: IQTextInputViewInfo) {

        if textInputViewInfo != info {
#if compiler(>=5.7)    // Xcode 14
            if #available(iOS 16.0, *),
               info.textInputView.iqIsFindInteractionEnabled {
                findInteractionTextInputViewInfo = textInputViewInfo
            } else {
                findInteractionTextInputViewInfo = nil
            }
#else
            findInteractionTextInputViewInfo = nil
#endif
            textInputViewInfo = info
            sendEvent(info: info)
            textInputViewInfo = nil
        }
    }
}

@available(iOSApplicationExtension, unavailable)
@MainActor
@objc public extension IQTextInputViewNotification {

    typealias TextInputViewCompletion = (_ event: IQTextInputViewInfo.Event,
                                         _ textInputView: any IQTextInputView) -> Void

    func subscribe(identifier: AnyHashable, changeHandler: @escaping TextInputViewCompletion) {
        textInputViewObservers[identifier] = changeHandler

        if let textInputViewInfo = textInputViewInfo {
            changeHandler(textInputViewInfo.event, textInputViewInfo.textInputView)
        }
    }

    func unsubscribe(identifier: AnyHashable) {
        textInputViewObservers[identifier] = nil
    }

    func isSubscribed(identifier: AnyHashable) -> Bool {
        return textInputViewObservers[identifier] != nil
    }

    @nonobjc
    private func sendEvent(info: IQTextInputViewInfo) {

        for block in textInputViewObservers.values {
            block(info.event, info.textInputView)
        }
    }
}

// MARK: Deprecated
@available(iOSApplicationExtension, unavailable)
@MainActor
public extension IQTextInputViewNotification {

    @available(*, unavailable, renamed: "textInputViewInfo")
    var textFieldViewInfo: IQTextInputViewInfo? { textInputViewInfo }

    @available(*, unavailable, renamed: "textInputView")
    var textFieldView: (some IQTextInputView)? { textInputView }

    @available(*, unavailable, renamed: "subscribe(identifier:changeHandler:)")
    func registerTextFieldViewChange(identifier: AnyHashable, changeHandler: @escaping TextInputViewCompletion) {}

    @available(*, unavailable, renamed: "unsubscribe(identifier:)")
    func unregisterSizeChange(identifier: AnyHashable) {}
}

@available(*, unavailable, renamed: "IQTextInputViewNotification")
@MainActor
@objcMembers public final class IQTextFieldViewListener: NSObject {}

@available(iOSApplicationExtension, unavailable)
@MainActor
@objc public extension IQTextInputViewNotification {

    var textInputViewInfoObjc: IQTextInputViewInfoObjC? {
        guard let textInputViewInfo = textInputViewInfo else { return nil }
        return IQTextInputViewInfoObjC(wrappedValue: textInputViewInfo)
    }
}
