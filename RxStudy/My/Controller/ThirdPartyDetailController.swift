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

    /// The represented acknowledgement
    var acknowledgement: Acknow?

    /// Title for the detail view
    var detailTitle: String?
    var detailText: String?

    /**
     Initializes the `ThirdPartyDetailController` instance with a title and text.

     - parameter title: The title of the detail.
     - parameter text: The text content.

     - returns: The new `ThirdPartyDetailController` instance.
     */
    public init(title: String, text: String) {
        super.init(nibName: nil, bundle: nil)

        self.detailTitle = title
        self.detailText = text
    }

    /**
     Initializes the `ThirdPartyDetailController` instance with an acknowledgement.

     - parameter acknowledgement: The acknowledgement.

     - returns: The new `ThirdPartyDetailController` instance.
     */
    public init(acknowledgement: Acknow) {
        super.init(nibName: nil, bundle: nil)

        self.acknowledgement = acknowledgement
    }

    /**
     Initializes the `ThirdPartyDetailController` instance with a coder.

     - parameter aDecoder: The archive coder.

     - returns: The new `ThirdPartyDetailController` instance.
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

        title = detailTitle ?? "详情"

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
        textView.text = detailText ?? "暂无内容"
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
