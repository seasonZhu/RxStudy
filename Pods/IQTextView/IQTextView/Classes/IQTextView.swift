//
//  IQTextView.swift
//  https://github.com/hackiftekhar/IQTextView
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

/** @abstract UITextView with placeholder support   */
@available(iOSApplicationExtension, unavailable)
@MainActor
@objcMembers open class IQTextView: UITextView {

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    override public init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setup()
    }

    override open func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }

    private func setup() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.refreshPlaceholder),
                                               name: UITextView.textDidChangeNotification, object: self)

        do {
            placeholderLabel.frame = placeholderExpectedFrame
            placeholderLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            placeholderLabel.lineBreakMode = .byWordWrapping
            placeholderLabel.numberOfLines = 0
            placeholderLabel.font = self.font
            placeholderLabel.textAlignment = self.textAlignment
            placeholderLabel.backgroundColor = UIColor.clear
            placeholderLabel.isAccessibilityElement = false
            placeholderLabel.textColor = UIColor.placeholderText
            self.addSubview(placeholderLabel)
            refreshPlaceholder()
        }
    }

    private var placeholderInsets: UIEdgeInsets {
        let top: CGFloat = self.textContainerInset.top
        let left: CGFloat = self.textContainerInset.left + self.textContainer.lineFragmentPadding
        let bottom: CGFloat = self.textContainerInset.bottom
        let right: CGFloat = self.textContainerInset.right + self.textContainer.lineFragmentPadding
        return UIEdgeInsets(top: top, left: left, bottom: bottom, right: right)
    }

    private var placeholderExpectedFrame: CGRect {
        let insets: UIEdgeInsets = self.placeholderInsets
        let maxWidth: CGFloat = self.frame.width-insets.left-insets.right
        let size: CGSize = CGSize(width: maxWidth, height: self.frame.height-insets.top-insets.bottom)
        let expectedSize: CGSize = placeholderLabel.sizeThatFits(size)

        return CGRect(x: insets.left, y: insets.top, width: maxWidth, height: expectedSize.height)
    }

    public let placeholderLabel: UILabel = .init()

    /** @abstract To set textView's placeholder text color. */
    @IBInspectable open var placeholderTextColor: UIColor? {

        get {
            return placeholderLabel.textColor
        }

        set {
            placeholderLabel.textColor = newValue
        }
    }

    /** @abstract To set textView's placeholder text. Default is nil.    */
    @IBInspectable open var placeholder: String? {

        get {
            return placeholderLabel.text
        }

        set {
            placeholderLabel.text = newValue
            refreshPlaceholder()
        }
    }

    /** @abstract To set textView's placeholder attributed text. Default is nil.    */
    open var attributedPlaceholder: NSAttributedString? {
        get {
            return placeholderLabel.attributedText
        }

        set {
            placeholderLabel.attributedText = newValue
            refreshPlaceholder()
        }
    }

    open override func layoutSubviews() {
        super.layoutSubviews()

        placeholderLabel.frame = placeholderExpectedFrame
    }

    @objc private func refreshPlaceholder() {

        let text: String = text ?? attributedText?.string ?? ""
        placeholderLabel.alpha = text.isEmpty ? 1 : 0
    }

    open override var text: String! {

        didSet {
            refreshPlaceholder()
        }
    }

    open override var attributedText: NSAttributedString! {

        didSet {
            refreshPlaceholder()
        }
    }

    open override var font: UIFont? {

        didSet {

            if let font: UIFont = font {
                placeholderLabel.font = font
            } else {
                placeholderLabel.font = UIFont.systemFont(ofSize: 12)
            }
        }
    }

    open override var textAlignment: NSTextAlignment {
        didSet {
            placeholderLabel.textAlignment = textAlignment
        }
    }

    open override var intrinsicContentSize: CGSize {
        guard !hasText else {
            return super.intrinsicContentSize
        }

        var newSize: CGSize = super.intrinsicContentSize
        let placeholderInsets: UIEdgeInsets = self.placeholderInsets
        newSize.height = placeholderExpectedFrame.height + placeholderInsets.top + placeholderInsets.bottom

        return newSize
    }

    open override func caretRect(for position: UITextPosition) -> CGRect {
        var originalRect = super.caretRect(for: position)

        // When placeholder is visible and text alignment is centered
        guard placeholderLabel.alpha == 1 && self.textAlignment == .center else { return originalRect }

        // Calculate the width of the placeholder text
        let font = placeholderLabel.font ?? UIFont.systemFont(ofSize: UIFont.systemFontSize)
        let textSize = placeholderLabel.text?.size(withAttributes: [.font: font]) ?? .zero
        // Calculate the starting x position of the centered placeholder text
        let centeredTextX = (self.bounds.size.width - textSize.width) / 2
        // Update the caret position to match the starting x position of the centered text
        originalRect.origin.x = centeredTextX

        return originalRect
    }
}
