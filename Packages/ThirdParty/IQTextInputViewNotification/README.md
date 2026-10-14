# IQTextInputViewNotification

[![CI Status](https://img.shields.io/travis/hackiftekhar/IQTextInputViewNotification.svg?style=flat)](https://travis-ci.org/hackiftekhar/IQTextInputViewNotification)
[![Version](https://img.shields.io/cocoapods/v/IQTextInputViewNotification.svg?style=flat)](https://cocoapods.org/pods/IQTextInputViewNotification)
[![License](https://img.shields.io/cocoapods/l/IQTextInputViewNotification.svg?style=flat)](https://cocoapods.org/pods/IQTextInputViewNotification)
[![Platform](https://img.shields.io/cocoapods/p/IQTextInputViewNotification.svg?style=flat)](https://cocoapods.org/pods/IQTextInputViewNotification)

![Screenshot](https://raw.githubusercontent.com/hackiftekhar/IQTextInputViewNotification/master/Screenshot/IQTextInputViewNotificationScreenshot.png)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

IQTextInputViewNotification is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'IQTextInputViewNotification'
```

## Usage

To observe textInputView becomeFirstResponder and resignFirstResponder changes, subscribe to the textInputView events:-

```swift
import IQTextInputViewNotification

class ViewController: UIViewController {

    private let textInputViewObserver: IQTextInputViewNotification = .init()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Subscribe
        textInputViewObserver.subscribe(identifier: "YOUR_UNIQUE_IDENTIFIER") {info in
            print(info.event.name) // BeginEditing or EndEditing event
            print(info.textInputView) // TextInputView which begin editing or end editing
            // Write your own logic here based on event
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Unsubscribe
        textInputViewObserver.unsubscribe(identifier: "YOUR_UNIQUE_IDENTIFIER")
    }
}
```

## Author

Iftekhar Qurashi hack.iftekhar@gmail.com

## Flow

![Screenshot](https://raw.githubusercontent.com/hackiftekhar/IQTextInputViewNotification/master/Screenshot/FlowDiagram.jpg)

## License

IQTextInputViewNotification is available under the MIT license. See the LICENSE file for more info.
