//
//  ThirdPartyDetailController.swift
//  RxStudy
//
//  Created by season on 2021/6/21.
//  Copyright © 2021 season. All rights reserved.
//

import UIKit

import AcknowList

class ThirdPartyDetailController: BaseViewController {

    /// The main text view.
    open var textView: UITextView?

    /// The represented acknowledgement.
    var acknowledgement: Acknow?

    /**
     Initializes the `AcknowViewController` instance with an acknowledgement.

     - parameter acknowledgement: The represented acknowledgement.

     - returns: The new `AcknowViewController` instance.
     */
    public init(acknowledgement: Acknow) {
        super.init(nibName: nil, bundle: nil)

        self.title = acknowledgement.title
        self.acknowledgement = acknowledgement
    }

    /**
     Initializes the `AcknowViewController` instance with a coder.

     - parameter aDecoder: The archive coder.

     - returns: The new `AcknowViewController` instance.
     */
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: - View lifecycle

    let DefaultMarginTopBottom: CGFloat = 20
    let DefaultMarginLeftRight: CGFloat = 10

    /// Called after the controller's view is loaded into memory.
    open override func viewDidLoad() {
        super.viewDidLoad()

        let textView = UITextView(frame: view.bounds)
        textView.alwaysBounceVertical = true
        textView.font = .preferredFont(forTextStyle: .body)
        textView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        #if os(iOS)
            textView.isEditable = false
            textView.dataDetectorTypes = .link
        #elseif os(tvOS)
            textView.isUserInteractionEnabled = true
            textView.panGestureRecognizer.allowedTouchTypes = [NSNumber(value: UITouch.TouchType.indirect.rawValue)]
        #endif
        textView.textContainerInset = UIEdgeInsets(top: DefaultMarginTopBottom, left: DefaultMarginLeftRight, bottom: DefaultMarginTopBottom, right: DefaultMarginLeftRight)
        view.addSubview(textView)

        self.textView = textView
    }

    /// Called to notify the view controller that its view has just laid out its subviews.
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if let textView {
            updateTextViewInsets(textView)
        }

        // Need to set the textView text after the layout is completed, so that the content inset and offset properties can be adjusted automatically.
        if let acknowledgement {
            textView?.text = acknowledgement.text
        }
    }

    @available(iOS 11.0, tvOS 11.0, *) open override func viewLayoutMarginsDidChange() {
        super.viewLayoutMarginsDidChange()

        if let textView = textView {
            updateTextViewInsets(textView)
        }
    }

    func updateTextViewInsets(_ textView: UITextView) {
        textView.textContainerInset = UIEdgeInsets(top: DefaultMarginTopBottom, left: view.layoutMargins.left, bottom: DefaultMarginTopBottom, right: view.layoutMargins.right)
    }
}
