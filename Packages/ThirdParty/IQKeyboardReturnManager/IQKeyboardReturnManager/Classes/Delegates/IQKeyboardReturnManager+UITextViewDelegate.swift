//
//  IQKeyboardReturnManager+UITextViewDelegate.swift
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

// MARK: UITextViewDelegate
@available(iOSApplicationExtension, unavailable)
@MainActor
@objc extension IQKeyboardReturnManager: UITextViewDelegate {
}

@objc public extension IQKeyboardReturnManager {

    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {

        var returnValue: Bool = true

        if delegate == nil,
           let textViewDelegate: any UITextViewDelegate = textInputViewCachedInfo(textView)?.textViewDelegate {
            if textViewDelegate.responds(to: #selector((any UITextViewDelegate).textViewShouldBeginEditing(_:))) {
                returnValue = textViewDelegate.textViewShouldBeginEditing?(textView) ?? false
            }
        }

        if returnValue {
            updateReturnKey(textInputView: textView)
        }

        return returnValue
    }

    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {

        guard delegate == nil else { return true }

        if let textViewDelegate: any UITextViewDelegate = textInputViewCachedInfo(textView)?.textViewDelegate {
            if textViewDelegate.responds(to: #selector((any UITextViewDelegate).textViewShouldEndEditing(_:))) {
                return textViewDelegate.textViewShouldEndEditing?(textView) ?? false
            }
        }

        return true
    }

    func textViewDidBeginEditing(_ textView: UITextView) {

        var aDelegate: (any UITextViewDelegate)? = delegate

        if aDelegate == nil {

            if let model: IQTextInputViewInfoModel = textInputViewCachedInfo(textView) {
                aDelegate = model.textViewDelegate
            }
        }

        aDelegate?.textViewDidBeginEditing?(textView)
    }

    func textViewDidEndEditing(_ textView: UITextView) {

        var aDelegate: (any UITextViewDelegate)? = delegate

        if aDelegate == nil {

            if let model: IQTextInputViewInfoModel = textInputViewCachedInfo(textView) {
                aDelegate = model.textViewDelegate
            }
        }

        aDelegate?.textViewDidEndEditing?(textView)
    }

    func textView(_ textView: UITextView,
                               shouldChangeTextIn range: NSRange,
                               replacementText text: String) -> Bool {

        var shouldChange = true

        if delegate == nil {

            if let textViewDelegate: any UITextViewDelegate = textInputViewCachedInfo(textView)?.textViewDelegate {
                let selector = #selector((any UITextViewDelegate).textView(_:shouldChangeTextIn:replacementText:))
                if textViewDelegate.responds(to: selector) {
                    shouldChange = (textViewDelegate.textView?(textView,
                                                               shouldChangeTextIn: range,
                                                               replacementText: text)) ?? true
                }
            }
        }

        if self.dismissTextViewOnReturn, text == "\n" {
            goToNextResponderOrResign(from: textView)
            return false
        }

        return shouldChange
    }

    func textViewDidChange(_ textView: UITextView) {

        var aDelegate: (any UITextViewDelegate)? = delegate

        if aDelegate == nil {

            if let model: IQTextInputViewInfoModel = textInputViewCachedInfo(textView) {
                aDelegate = model.textViewDelegate
            }
        }

        aDelegate?.textViewDidChange?(textView)
    }

    func textViewDidChangeSelection(_ textView: UITextView) {

        var aDelegate: (any UITextViewDelegate)? = delegate

        if aDelegate == nil {

            if let model: IQTextInputViewInfoModel = textInputViewCachedInfo(textView) {
                aDelegate = model.textViewDelegate
            }
        }

        aDelegate?.textViewDidChangeSelection?(textView)
    }

    @available(iOS, deprecated: 17.0)
    func textView(_ aTextView: UITextView,
                               shouldInteractWith URL: URL,
                               in characterRange: NSRange,
                               interaction: UITextItemInteraction) -> Bool {

        guard delegate == nil else { return true }

        if let textViewDelegate: any UITextViewDelegate = textInputViewCachedInfo(aTextView)?.textViewDelegate {

            let selector: Selector = #selector(textView as (UITextView, URL, NSRange, UITextItemInteraction) -> Bool)
            if textViewDelegate.responds(to: selector) {
                return textViewDelegate.textView?(aTextView,
                                                  shouldInteractWith: URL,
                                                  in: characterRange,
                                                  interaction: interaction) ?? false
            }
        }

        return true
    }

    @available(iOS, deprecated: 17.0)
    func textView(_ aTextView: UITextView,
                               shouldInteractWith textAttachment: NSTextAttachment,
                               in characterRange: NSRange,
                               interaction: UITextItemInteraction) -> Bool {

        guard delegate == nil else { return true }

        if let textViewDelegate: any UITextViewDelegate = textInputViewCachedInfo(aTextView)?.textViewDelegate {
            let selector: Selector = #selector(textView as
                                               (UITextView, NSTextAttachment, NSRange, UITextItemInteraction)
                                               -> Bool)
            if textViewDelegate.responds(to: selector) {
                return textViewDelegate.textView?(aTextView,
                                                  shouldInteractWith: textAttachment,
                                                  in: characterRange,
                                                  interaction: interaction) ?? false
            }
        }

        return true
    }

    @available(iOS, deprecated: 10.0)
    func textView(_ aTextView: UITextView,
                               shouldInteractWith URL: URL,
                               in characterRange: NSRange) -> Bool {

        guard delegate == nil else { return true }

        if let textViewDelegate: any UITextViewDelegate = textInputViewCachedInfo(aTextView)?.textViewDelegate {

            let selector: Selector = #selector(textView as (UITextView, URL, NSRange) -> Bool)

            if textViewDelegate.responds(to: selector) {
                return textViewDelegate.textView?(aTextView,
                                                  shouldInteractWith: URL,
                                                  in: characterRange) ?? false
            }
        }

        return true
    }

    @available(iOS, deprecated: 10.0)
    func textView(_ aTextView: UITextView,
                               shouldInteractWith textAttachment: NSTextAttachment,
                               in characterRange: NSRange) -> Bool {

        guard delegate == nil else { return true }

        if let textViewDelegate: any UITextViewDelegate = textInputViewCachedInfo(aTextView)?.textViewDelegate {

            let selector: Selector = #selector(textView as (UITextView, NSTextAttachment, NSRange) -> Bool)

            if textViewDelegate.responds(to: selector) {
                return textViewDelegate.textView?(aTextView,
                                                  shouldInteractWith: textAttachment,
                                                  in: characterRange) ?? false
            }
        }

        return true
    }
}

#if compiler(>=5.7)    // Xcode 14
@available(iOS 16.0, *)
@available(iOSApplicationExtension, unavailable)
@MainActor
@objc public extension IQKeyboardReturnManager {
    func textView(_ aTextView: UITextView,
                               editMenuForTextIn range: NSRange,
                               suggestedActions: [UIMenuElement]) -> UIMenu? {

        guard delegate == nil else { return nil }

        if let textViewDelegate: any UITextViewDelegate = textInputViewCachedInfo(aTextView)?.textViewDelegate {

            let selector = #selector((any UITextViewDelegate).textView(_:editMenuForTextIn:suggestedActions:))
            if textViewDelegate.responds(to: selector) {
                return textViewDelegate.textView?(aTextView,
                                                  editMenuForTextIn: range,
                                                  suggestedActions: suggestedActions)
            }
        }

        return nil
    }

    func textView(_ aTextView: UITextView,
                               willPresentEditMenuWith animator: any UIEditMenuInteractionAnimating) {
        var aDelegate: (any UITextViewDelegate)? = delegate

        if aDelegate == nil {

            if let model: IQTextInputViewInfoModel = textInputViewCachedInfo(aTextView) {
                aDelegate = model.textViewDelegate
            }
        }

        aDelegate?.textView?(aTextView, willPresentEditMenuWith: animator)
    }

    func textView(_ aTextView: UITextView,
                               willDismissEditMenuWith animator: any UIEditMenuInteractionAnimating) {
        var aDelegate: (any UITextViewDelegate)? = delegate

        if aDelegate == nil {

            if let model: IQTextInputViewInfoModel = textInputViewCachedInfo(aTextView) {
                aDelegate = model.textViewDelegate
            }
        }

        aDelegate?.textView?(aTextView, willDismissEditMenuWith: animator)
    }
}
#endif

#if compiler(>=5.9)    // Xcode 15
@available(iOS 17.0, *)
@available(iOSApplicationExtension, unavailable)
@MainActor
@objc public extension IQKeyboardReturnManager {

    func textView(_ aTextView: UITextView,
                        primaryActionFor textItem: UITextItem,
                        defaultAction: UIAction) -> UIAction? {
        guard delegate == nil else { return nil }

        if let textViewDelegate = textInputViewCachedInfo(aTextView)?.textViewDelegate {
            let selector = #selector((any UITextViewDelegate).textView(_:primaryActionFor:defaultAction:))

            if textViewDelegate.responds(to: selector) {
                return textViewDelegate.textView?(aTextView,
                                                  primaryActionFor: textItem,
                                                  defaultAction: defaultAction)
            }
        }

        return nil
    }

    func textView(_ aTextView: UITextView,
                        menuConfigurationFor textItem: UITextItem,
                        defaultMenu: UIMenu) -> UITextItem.MenuConfiguration? {
        guard delegate == nil else { return nil }

        if let textViewDelegate = textInputViewCachedInfo(aTextView)?.textViewDelegate {
            let selector = #selector((any UITextViewDelegate).textView(_:menuConfigurationFor:defaultMenu:))
            if textViewDelegate.responds(to: selector) {
                return textViewDelegate.textView?(aTextView,
                                                  menuConfigurationFor: textItem,
                                                  defaultMenu: defaultMenu)
            }
        }

        return nil
    }

    func textView(_ textView: UITextView,
                        textItemMenuWillDisplayFor textItem: UITextItem,
                        animator: any UIContextMenuInteractionAnimating) {
        var aDelegate: (any UITextViewDelegate)? = delegate

        if aDelegate == nil {

            if let model = textInputViewCachedInfo(textView) {
                aDelegate = model.textViewDelegate
            }
        }

        aDelegate?.textView?(textView, textItemMenuWillDisplayFor: textItem, animator: animator)
    }

    func textView(_ textView: UITextView,
                        textItemMenuWillEndFor textItem: UITextItem,
                        animator: any UIContextMenuInteractionAnimating) {
        var aDelegate: (any UITextViewDelegate)? = delegate

        if aDelegate == nil {

            if let model = textInputViewCachedInfo(textView) {
                aDelegate = model.textViewDelegate
            }
        }

        aDelegate?.textView?(textView, textItemMenuWillEndFor: textItem, animator: animator)
    }
}
#endif

#if compiler(>=6.0)    // Xcode 16
@available(iOS 18.0, *)
@available(iOSApplicationExtension, unavailable)
@MainActor
@objc public extension IQKeyboardReturnManager {

    func textViewWritingToolsWillBegin(_ textView: UITextView) {

        var aDelegate: (any UITextViewDelegate)? = delegate

        if aDelegate == nil {

            if let model: IQTextInputViewInfoModel = textInputViewCachedInfo(textView) {
                aDelegate = model.textViewDelegate
            }
        }

        aDelegate?.textViewWritingToolsWillBegin?(textView)
    }

    func textViewWritingToolsDidEnd(_ textView: UITextView) {

        var aDelegate: (any UITextViewDelegate)? = delegate

        if aDelegate == nil {

            if let model: IQTextInputViewInfoModel = textInputViewCachedInfo(textView) {
                aDelegate = model.textViewDelegate
            }
        }

        aDelegate?.textViewWritingToolsDidEnd?(textView)
    }

    func textView(_ textView: UITextView,
                               writingToolsIgnoredRangesInEnclosingRange enclosingRange: NSRange) -> [NSValue] {
        guard delegate == nil else { return [] }

        if let textViewDelegate = textInputViewCachedInfo(textView)?.textViewDelegate {
            let selector = #selector((any UITextViewDelegate).textView(_:writingToolsIgnoredRangesInEnclosingRange:))
            if textViewDelegate.responds(to: selector) {
                return textViewDelegate.textView?(textView,
                                                  writingToolsIgnoredRangesInEnclosingRange: enclosingRange) ?? []
            }
        }
        return []
    }

    func textView(_ textView: UITextView, willBeginFormattingWith viewController: UITextFormattingViewController) {

        var aDelegate: (any UITextViewDelegate)? = delegate

        if aDelegate == nil {

            if let model: IQTextInputViewInfoModel = textInputViewCachedInfo(textView) {
                aDelegate = model.textViewDelegate
            }
        }

        aDelegate?.textView?(textView, willBeginFormattingWith: viewController)
    }

    func textView(_ textView: UITextView, didBeginFormattingWith viewController: UITextFormattingViewController) {

        var aDelegate: (any UITextViewDelegate)? = delegate

        if aDelegate == nil {

            if let model: IQTextInputViewInfoModel = textInputViewCachedInfo(textView) {
                aDelegate = model.textViewDelegate
            }
        }

        aDelegate?.textView?(textView, didBeginFormattingWith: viewController)
    }

    func textView(_ textView: UITextView, willEndFormattingWith viewController: UITextFormattingViewController) {

        var aDelegate: (any UITextViewDelegate)? = delegate

        if aDelegate == nil {

            if let model: IQTextInputViewInfoModel = textInputViewCachedInfo(textView) {
                aDelegate = model.textViewDelegate
            }
        }

        aDelegate?.textView?(textView, willEndFormattingWith: viewController)
    }

    func textView(_ textView: UITextView, didEndFormattingWith viewController: UITextFormattingViewController) {

        var aDelegate: (any UITextViewDelegate)? = delegate

        if aDelegate == nil {

            if let model: IQTextInputViewInfoModel = textInputViewCachedInfo(textView) {
                aDelegate = model.textViewDelegate
            }
        }

        aDelegate?.textView?(textView, didEndFormattingWith: viewController)
    }

#if compiler(>=6.1)    // Xcode 16.3
    @available(iOS 18.4, *)
    func textView(_ textView: UITextView, insertInputSuggestion inputSuggestion: UIInputSuggestion) {

        var aDelegate: (any UITextViewDelegate)? = delegate

        if aDelegate == nil {

            if let model: IQTextInputViewInfoModel = textInputViewCachedInfo(textView) {
                aDelegate = model.textViewDelegate
            }
        }

        aDelegate?.textView?(textView, insertInputSuggestion: inputSuggestion)
    }
#endif
}
#endif

#if compiler(>=6.2)    // Xcode 26
@available(iOS 26.0, *)
@available(iOSApplicationExtension, unavailable)
@MainActor
@objc public extension IQKeyboardReturnManager {

    func textView(_ textView: UITextView, shouldChangeTextInRanges ranges: [NSValue], replacementText text: String) -> Bool {

        var shouldChange = true

        if delegate == nil {

            if let textViewDelegate: any UITextViewDelegate = textInputViewCachedInfo(textView)?.textViewDelegate {
                let selector = #selector((any UITextViewDelegate).textView(_:shouldChangeTextInRanges:replacementText:))
                if textViewDelegate.responds(to: selector) {
                    shouldChange = (textViewDelegate.textView?(textView,
                                                               shouldChangeTextInRanges: ranges,
                                                               replacementText: text)) ?? true
                }
            }
        }

        if self.dismissTextViewOnReturn, text == "\n" {
            goToNextResponderOrResign(from: textView)
            return false
        }

        return shouldChange
    }

    func textView(_ textView: UITextView, editMenuForTextInRanges ranges: [NSValue], suggestedActions: [UIMenuElement]) -> UIMenu? {

        guard delegate == nil else { return nil }

        if let textViewDelegate: any UITextViewDelegate = textInputViewCachedInfo(textView)?.textViewDelegate {

            let selector = #selector((any UITextViewDelegate).textView(_:editMenuForTextInRanges:suggestedActions:))
            if textViewDelegate.responds(to: selector) {
                return textViewDelegate.textView?(textView,
                                                  editMenuForTextInRanges: ranges,
                                                  suggestedActions: suggestedActions)
            }
        }

        return nil
    }
}
#endif
