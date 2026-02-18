# IQKeyboardNotification
Lightweight library to observe keyboard events with ease.

[![CI Status](https://img.shields.io/travis/hackiftekhar/IQKeyboardNotification.svg?style=flat)](https://travis-ci.org/hackiftekhar/IQKeyboardNotification)
[![Version](https://img.shields.io/cocoapods/v/IQKeyboardNotification.svg?style=flat)](https://cocoapods.org/pods/IQKeyboardNotification)
[![License](https://img.shields.io/cocoapods/l/IQKeyboardNotification.svg?style=flat)](https://cocoapods.org/pods/IQKeyboardNotification)
[![Platform](https://img.shields.io/cocoapods/p/IQKeyboardNotification.svg?style=flat)](https://cocoapods.org/pods/IQKeyboardNotification)

![Screenshot](https://raw.githubusercontent.com/hackiftekhar/IQKeyboardNotification/master/Screenshot/IQKeyboardNotificationScreenshot.png)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

IQKeyboardNotification is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'IQKeyboardNotification'
```

## Usage

To observe keyboard events, subscribe to the keyboard events:-

```swift
import IQKeyboardNotification

class ViewController: UIViewController {

    private let keyboard: IQKeyboardNotification = .init()

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Subscribe
        keyboard.subscribe(identifier: "YOUR_UNIQUE_IDENTIFIER") { event, frame in
            print(frame)
            // Write your own logic here based on event and keyboard frame
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Unsubscribe
        keyboard.unsubscribe(identifier: "YOUR_UNIQUE_IDENTIFIER")
    }
}
```

## Author

Iftekhar Qurashi hack.iftekhar@gmail.com

## Flow

![Screenshot](https://raw.githubusercontent.com/hackiftekhar/IQKeyboardNotification/master/Screenshot/FlowDiagram.jpg)

## License

IQKeyboardNotification is available under the MIT license. See the LICENSE file for more info.
