//
//  IQKeyboardReturnManager+UITextFieldDelegate.swift
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

// MARK: UITextFieldDelegate
@available(iOSApplicationExtension, unavailable)
@MainActor
@objc extension IQKeyboardReturnManager: UITextFieldDelegate {
}

@objc public extension IQKeyboardReturnManager {

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {

        var returnValue: Bool = true

        if delegate == nil,
           let textFieldDelegate: any UITextFieldDelegate = textInputViewCachedInfo(textField)?.textFieldDelegate {
            let selector = #selector((any UITextFieldDelegate).textFieldShouldBeginEditing(_:))
            if textFieldDelegate.responds(to: selector) {
                returnValue = textFieldDelegate.textFieldShouldBeginEditing?(textField) ?? false
            }
        }

        if returnValue {
            updateReturnKey(textInputView: textField)
        }

        return returnValue
    }

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {

        guard delegate == nil else { return true }

        if let textFieldDelegate: any UITextFieldDelegate = textInputViewCachedInfo(textField)?.textFieldDelegate {
            let selector = #selector((any UITextFieldDelegate).textFieldShouldEndEditing(_:))
            if textFieldDelegate.responds(to: selector) {
                return textFieldDelegate.textFieldShouldEndEditing?(textField) ?? false
            }
        }

        return true
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {

        var aDelegate: (any UITextFieldDelegate)? = delegate

        if aDelegate == nil {

            if let model: IQTextInputViewInfoModel = textInputViewCachedInfo(textField) {
                aDelegate = model.textFieldDelegate
            }
        }

        aDelegate?.textFieldDidBeginEditing?(textField)
    }

    func textFieldDidEndEditing(_ textField: UITextField) {

        var aDelegate: (any UITextFieldDelegate)? = delegate

        if aDelegate == nil {

            if let model: IQTextInputViewInfoModel = textInputViewCachedInfo(textField) {
                aDelegate = model.textFieldDelegate
            }
        }

        aDelegate?.textFieldDidEndEditing?(textField)
    }

    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {

        var aDelegate: (any UITextFieldDelegate)? = delegate

        if aDelegate == nil {

            if let model: IQTextInputViewInfoModel = textInputViewCachedInfo(textField) {
                aDelegate = model.textFieldDelegate
            }
        }

        aDelegate?.textFieldDidEndEditing?(textField, reason: reason)
    }

    func textField(_ textField: UITextField,
                                shouldChangeCharactersIn range: NSRange,
                                replacementString string: String) -> Bool {

        guard delegate == nil else { return true }

        if let textFieldDelegate: any UITextFieldDelegate = textInputViewCachedInfo(textField)?.textFieldDelegate {
            let selector: Selector = #selector((any UITextFieldDelegate).textField(_:shouldChangeCharactersIn:
                                                                                    replacementString:))
            if textFieldDelegate.responds(to: selector) {
                return textFieldDelegate.textField?(textField,
                                                    shouldChangeCharactersIn: range,
                                                    replacementString: string) ?? false
            }
        }
        return true
    }

    func textFieldDidChangeSelection(_ textField: UITextField) {

        var aDelegate: (any UITextFieldDelegate)? = delegate

        if aDelegate == nil {

            if let model: IQTextInputViewInfoModel = textInputViewCachedInfo(textField) {
                aDelegate = model.textFieldDelegate
            }
        }

        aDelegate?.textFieldDidChangeSelection?(textField)
    }

    func textFieldShouldClear(_ textField: UITextField) -> Bool {

        guard delegate == nil else { return true }

        if let textFieldDelegate: any UITextFieldDelegate = textInputViewCachedInfo(textField)?.textFieldDelegate {
            let selector: Selector = #selector((any UITextFieldDelegate).textFieldShouldClear(_:))
            if textFieldDelegate.responds(to: selector) {
                return textFieldDelegate.textFieldShouldClear?(textField) ?? false
            }
        }

        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        guard delegate == nil else { return true }

        var isReturn: Bool = true

        if let textFieldDelegate: any UITextFieldDelegate = textInputViewCachedInfo(textField)?.textFieldDelegate {
            let selector: Selector = #selector((any UITextFieldDelegate).textFieldShouldReturn(_:))
            if textFieldDelegate.responds(to: selector) {
                isReturn = textFieldDelegate.textFieldShouldReturn?(textField) ?? false
            }
        }

        if isReturn {
            goToNextResponderOrResign(from: textField)
            return true
        } else {
            return goToNextResponderOrResign(from: textField)
        }
    }
}

#if compiler(>=5.7)    // Xcode 14
@available(iOS 16.0, *)
@available(iOSApplicationExtension, unavailable)
@MainActor
@objc public extension IQKeyboardReturnManager {

    func textField(_ textField: UITextField, editMenuForCharactersIn range: NSRange, suggestedActions: [UIMenuElement]) -> UIMenu? {

        guard delegate == nil else { return nil }

        if let textFieldDelegate: any UITextFieldDelegate = textInputViewCachedInfo(textField)?.textFieldDelegate {

            let selector = #selector((any UITextFieldDelegate).textField(_:editMenuForCharactersIn:suggestedActions:))
            if textFieldDelegate.responds(to: selector) {
                return textFieldDelegate.textField?(textField, editMenuForCharactersIn: range, suggestedActions: suggestedActions)
            }
        }

        return nil
    }

    func textField(_ textField: UITextField, willPresentEditMenuWith animator: any UIEditMenuInteractionAnimating) {
        var aDelegate: (any UITextFieldDelegate)? = delegate

        if aDelegate == nil {

            if let model: IQTextInputViewInfoModel = textInputViewCachedInfo(textField) {
                aDelegate = model.textFieldDelegate
            }
        }

        aDelegate?.textField?(textField, willPresentEditMenuWith: animator)
    }

    func textField(_ textField: UITextField, willDismissEditMenuWith animator: any UIEditMenuInteractionAnimating) {
        var aDelegate: (any UITextFieldDelegate)? = delegate

        if aDelegate == nil {

            if let model: IQTextInputViewInfoModel = textInputViewCachedInfo(textField) {
                aDelegate = model.textFieldDelegate
            }
        }

        aDelegate?.textField?(textField, willDismissEditMenuWith: animator)
    }
}
#endif

#if compiler(>=6.0)    // Xcode 16
@available(iOS 18.0, *)
@available(iOSApplicationExtension, unavailable)
@MainActor
@objc public extension IQKeyboardReturnManager {

#if compiler(>=6.1)    // Xcode 16.3
    @available(iOS 18.4, *)
    func textField(_ textField: UITextField, insertInputSuggestion inputSuggestion: UIInputSuggestion) {
        var aDelegate: (any UITextFieldDelegate)? = delegate

        if aDelegate == nil {

            if let model: IQTextInputViewInfoModel = textInputViewCachedInfo(textField) {
                aDelegate = model.textFieldDelegate
            }
        }

        aDelegate?.textField?(textField, insertInputSuggestion: inputSuggestion)
    }
#endif
}
#endif

#if compiler(>=6.2)    // Xcode 26
@available(iOS 26.0, *)
@available(iOSApplicationExtension, unavailable)
@MainActor
@objc public extension IQKeyboardReturnManager {

    func textField(_ textField: UITextField, shouldChangeCharactersInRanges ranges: [NSValue], replacementString string: String) -> Bool {
        guard delegate == nil else { return true }

        if let textFieldDelegate: any UITextFieldDelegate = textInputViewCachedInfo(textField)?.textFieldDelegate {
            let selector: Selector = #selector((any UITextFieldDelegate).textField(_:shouldChangeCharactersInRanges:
                                                                                    replacementString:))
            if textFieldDelegate.responds(to: selector) {
                return textFieldDelegate.textField?(textField,
                                                    shouldChangeCharactersInRanges: ranges,
                                                    replacementString: string) ?? false
            }
        }
        return true
    }

    func textField(_ textField: UITextField, editMenuForCharactersInRanges ranges: [NSValue], suggestedActions: [UIMenuElement]) -> UIMenu? {

        guard delegate == nil else { return nil }

        if let textFieldDelegate: any UITextFieldDelegate = textInputViewCachedInfo(textField)?.textFieldDelegate {

            let selector = #selector((any UITextFieldDelegate).textField(_:editMenuForCharactersInRanges:suggestedActions:))
            if textFieldDelegate.responds(to: selector) {
                return textFieldDelegate.textField?(textField, editMenuForCharactersInRanges: ranges, suggestedActions: suggestedActions)
            }
        }

        return nil
    }
}
#endif
