# IQKeyboardReturnManager

[![CI Status](https://img.shields.io/travis/hackiftekhar/IQKeyboardReturnManager.svg?style=flat)](https://travis-ci.org/hackiftekhar/IQKeyboardReturnManager)
[![Version](https://img.shields.io/cocoapods/v/IQKeyboardReturnManager.svg?style=flat)](https://cocoapods.org/pods/IQKeyboardReturnManager)
[![License](https://img.shields.io/cocoapods/l/IQKeyboardReturnManager.svg?style=flat)](https://cocoapods.org/pods/IQKeyboardReturnManager)
[![Platform](https://img.shields.io/cocoapods/p/IQKeyboardReturnManager.svg?style=flat)](https://cocoapods.org/pods/IQKeyboardReturnManager)

![Screenshot](https://raw.githubusercontent.com/hackiftekhar/IQKeyboardReturnManager/master/Screenshot/IQKeyboardReturnManagerScreenshot.png)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

IQKeyboardReturnManager is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'IQKeyboardReturnManager'
```

## Usage

To handle keyboard return key automatically:-

```swift
import IQKeyboardReturnManager

class ViewController: UIViewController {

    let returnManager: IQKeyboardReturnManager = .init()

    override func viewDidLoad() {
        super.viewDidLoad()

        // This will add all textInputView of the controller and start observing for textFieldShouldReturn events
        returnManager.addResponderSubviews(of: self.view, recursive: true)

        // If you would like to dismiss the UITextView on tapping on return then add this
        returnManager.dismissTextViewOnReturn = true

        // If you would like to change last textInputView return key type to done or something else, then add this
        returnManager.lastTextInputViewReturnKeyType = .done

        // If you would like to customize the navigation between textField by your own order then add them manually
        returnManager.add(textInputView: textField1)
        returnManager.add(textInputView: textField2)
        returnManager.add(textInputView: textField3)
        returnManager.add(textInputView: textField4)
    }
}

// IQKeyboardReturnManager will forward all delegate callbacks to you, so you can customize the decisions 
extension ViewController: UITextFieldDelegate {
    @objc public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {...}
}
```

## Author

Iftekhar Qurashi hack.iftekhar@gmail.com

## License

IQKeyboardReturnManager is available under the MIT license. See the LICENSE file for more info.
