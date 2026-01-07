//
//  IQKeyboardReturnManager.swift
//  https://github.com/hackiftekhar/IQKeyboardReturnManager
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
import IQKeyboardCore

/**
Manages the return key to work like next/done in a view hierarchy.
*/
@available(iOSApplicationExtension, unavailable)
@MainActor
@objcMembers public final class IQKeyboardReturnManager: NSObject {

    // MARK: Private variables
    private var textInputViewInfoCache: [IQTextInputViewInfoModel] = []

    // MARK: Settings

    /**
     Delegate of textInputView
     */
    public weak var delegate: (any UITextFieldDelegate & UITextViewDelegate)?

    /**
     Set the last textInputView return key type. Default is UIReturnKeyDefault.
     */
    public var lastTextInputViewReturnKeyType: UIReturnKeyType = .default {

        didSet {
            if let activeModel = textInputViewInfoCache.first(where: {
                guard let textInputView = $0.textInputView else {
                    return false
                }
                return textInputView.isFirstResponder
            }), let view: any IQTextInputView = activeModel.textInputView {
                updateReturnKey(textInputView: view)
            }
        }
    }

    public var dismissTextViewOnReturn: Bool = false

    // MARK: Initialization/De-initialization

    public override init() {
        super.init()
    }

    @available(*, unavailable, message: "Please use addResponderSubviews(of:recursive:)")
    public init(controller: UIViewController) {
        super.init()
        addResponderSubviews(of: controller.view, recursive: true)
    }

    deinit {

        //        for model in textInputViewInfoCache {
        //            model.restore()
        //        }

        textInputViewInfoCache.removeAll()
    }
}

// MARK: Registering/Unregistering textInputView

@available(iOSApplicationExtension, unavailable)
@MainActor
@objc public extension IQKeyboardReturnManager {

    /**
     Should pass TextInputView instance. Assign textInputView delegate to self, change it's returnKeyType.

     @param textInputView TextInputView object to register.
     */
    func add(textInputView: any IQTextInputView) {

        let model = IQTextInputViewInfoModel(textInputView: textInputView)
        textInputViewInfoCache.append(model)

        if let view: UITextField = textInputView as? UITextField {
            view.delegate = self
        } else if let view: UITextView = textInputView as? UITextView {
            view.delegate = self
        }
    }

    /**
     Should pass TextInputView instance. Restore it's textInputView delegate and it's returnKeyType.

     @param textInputView TextInputView object to unregister.
     */
    func remove(textInputView: any IQTextInputView) {

        guard let index: Int = textInputViewCachedInfoIndex(textInputView) else { return }

        let model = textInputViewInfoCache.remove(at: index)
        model.restore()
    }

    /**
     Add all the TextInputView responderView's.

     @param view object to register all it's responder subviews.
     */
    func addResponderSubviews(of view: UIView, recursive: Bool) {

        let textInputViews: [any IQTextInputView] = view.responderSubviews(recursive: recursive)

        for view in textInputViews {
            add(textInputView: view)
        }
    }

    /**
     Remove all the TextInputView responderView's.

     @param view object to unregister all it's responder subviews.
     */
    func removeResponderSubviews(of view: UIView, recursive: Bool) {

        let textInputViews: [any IQTextInputView] = view.responderSubviews(recursive: recursive)

        for view in textInputViews {
            remove(textInputView: view)
        }
    }
}

@available(iOSApplicationExtension, unavailable)
@MainActor
@objc public extension IQKeyboardReturnManager {
    @discardableResult
    func goToNextResponderOrResign(from textInputView: any IQTextInputView) -> Bool {

        guard let textInfoCache: IQTextInputViewInfoModel = nextResponderFromTextInputView(textInputView),
              let textInputView = textInfoCache.textInputView else {
            textInputView.resignFirstResponder()
            return true
        }

        textInputView.becomeFirstResponder()
        return false
    }
}

// MARK: Internal Functions
@available(iOSApplicationExtension, unavailable)
@MainActor
internal extension IQKeyboardReturnManager {

    func nextResponderFromTextInputView(_ textInputView: some IQTextInputView) -> IQTextInputViewInfoModel? {
        guard let currentIndex: Int = textInputViewCachedInfoIndex(textInputView),
              currentIndex < textInputViewInfoCache.count - 1 else { return nil }

        let candidates = Array(textInputViewInfoCache[currentIndex+1..<textInputViewInfoCache.count])

        return candidates.first {
            guard let inputView = $0.textInputView,
                  inputView.isUserInteractionEnabled,
                  !inputView.isHidden, inputView.alpha != 0.0
            else { return false }

            return inputView.iqIsEnabled
        }
    }

    func textInputViewCachedInfoIndex(_ textInputView: some IQTextInputView) -> Int? {
        return textInputViewInfoCache.firstIndex {
            guard let inputView = $0.textInputView else { return false }
            return inputView == textInputView
        }
    }

    func textInputViewCachedInfo(_ textInputView: some IQTextInputView) -> IQTextInputViewInfoModel? {
        guard let index: Int = textInputViewCachedInfoIndex(textInputView) else { return nil }
        return textInputViewInfoCache[index]
    }

    func updateReturnKey(textInputView: some IQTextInputView) {

        let returnKey: UIReturnKeyType
        if nextResponderFromTextInputView(textInputView) != nil {
            returnKey = .next
        } else {
            returnKey = lastTextInputViewReturnKeyType
        }

        if textInputView.returnKeyType != returnKey {
            // If it's the last textInputView in responder view, else next
            textInputView.returnKeyType = returnKey
            textInputView.reloadInputViews()
        }
    }
}

// MARK: Deprecated
// swiftlint:disable unused_setter_value
@available(iOSApplicationExtension, unavailable)
@MainActor
@objc public extension IQKeyboardReturnManager {

    @available(*, unavailable, renamed: "lastTextInputViewReturnKeyType")
    var lastTextFieldReturnKeyType: UIReturnKeyType {
        get { .default }
        set { }
    }

    @available(*, unavailable, renamed: "add(textInputView:)")
    func addTextFieldView(_ textInputView: any IQTextInputView) { }

    @available(*, unavailable, renamed: "remove(textInputView:)")
    func removeTextFieldView(_ textInputView: any IQTextInputView) { }

    @available(*, unavailable, renamed: "addResponderSubviews(of:recursive:)")
    func addResponderFromView(_ view: UIView, recursive: Bool) { }

    @available(*, unavailable, renamed: "removeResponderSubviews(of:recursive:)")
    func removeResponderFromView(_ view: UIView, recursive: Bool = true) { }
}
// swiftlint:enable unused_setter_value

@available(iOSApplicationExtension, unavailable)
@MainActor
fileprivate extension UIView {

    func responderSubviews(recursive: Bool) -> [any IQTextInputView] {

        // Array of TextInputViews.
        var textInputViews: [any IQTextInputView] = []
        for view in subviews {

            if let view = view as? IQTextInputView {
                textInputViews.append(view)
            }
            // Sometimes there are hidden or disabled views and textInputView inside them still recorded,
            // so we added some more validations here (Bug ID: #458)
            // Uncommented else (Bug ID: #625)
            else if recursive, !view.subviews.isEmpty {
                let deepResponders = view.responderSubviews(recursive: recursive)
                textInputViews.append(contentsOf: deepResponders)
            }
        }

        // subviews are returning in opposite order. Sorting according the frames 'y'.
        return textInputViews.sorted(by: { (view1: any IQTextInputView, view2: any IQTextInputView) -> Bool in

            let frame1: CGRect = view1.convert(view1.bounds, to: self)
            let frame2: CGRect = view2.convert(view2.bounds, to: self)

            if frame1.minY != frame2.minY {
                return frame1.minY < frame2.minY
            } else {
                return frame1.minX < frame2.minX
            }
        })
    }
}
