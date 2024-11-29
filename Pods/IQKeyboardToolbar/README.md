# IQKeyboardToolbar

[![CI Status](https://img.shields.io/travis/hackiftekhar/IQKeyboardToolbar.svg?style=flat)](https://travis-ci.org/hackiftekhar/IQKeyboardToolbar)
[![Version](https://img.shields.io/cocoapods/v/IQKeyboardToolbar.svg?style=flat)](https://cocoapods.org/pods/IQKeyboardToolbar)
[![License](https://img.shields.io/cocoapods/l/IQKeyboardToolbar.svg?style=flat)](https://cocoapods.org/pods/IQKeyboardToolbar)
[![Platform](https://img.shields.io/cocoapods/p/IQKeyboardToolbar.svg?style=flat)](https://cocoapods.org/pods/IQKeyboardToolbar)

![Screenshot1](https://raw.githubusercontent.com/hackiftekhar/IQKeyboardToolbar/master/Screenshot/IQKeyboardToolbarScreenshot.png)
![Screenshot2](https://raw.githubusercontent.com/hackiftekhar/IQKeyboardToolbar/master/Screenshot/IQKeyboardToolbarScreenshot2.png)
![Screenshot3](https://raw.githubusercontent.com/hackiftekhar/IQKeyboardToolbar/master/Screenshot/IQKeyboardToolbarScreenshot3.png)
![Screenshot4](https://raw.githubusercontent.com/hackiftekhar/IQKeyboardToolbar/master/Screenshot/IQKeyboardToolbarScreenshot4.png)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

IQKeyboardToolbar is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'IQKeyboardToolbar'
```

## Usage

This library can be used to add toolbar to the keyboard

Previous Next and Done button
```swift
        textField.iq.addPreviousNextDone(target: self,
                                         previousAction: #selector(textField1PreviousAction),
                                         nextAction: #selector(textField1NextAction),
                                         doneAction: #selector(doneAction), showPlaceholder: true)
```

Previous Next and Right button with customized titles or images
```swift
        textField.iq.addPreviousNextRight(target: self,
                                          previousConfiguration: .init(title: "Prev", action: #selector(textView1PreviousAction)),
                                          nextConfiguration: .init(title: "Next", action: #selector(textView1NextAction)),
                                          rightConfiguration: .init(image: UIImage(systemName: "chevron.down")!, action: #selector(doneAction)),
                                          title: "Text View 1")
```

Action button
```swift
        textField.iq.addDone(target: self,
                             action: #selector(doneAction),
                             title: "Select Account")
        textField.iq.toolbar.titleBarButton.setTarget(self,
                                                      action: #selector(selectAccount))
```

Additional leading and trailing buttons
```swift
        textField.iq.toolbar.additionalLeadingItems = [.init(barButtonSystemItem: .add, target: self, action: #selector(addAction))]
        textField.iq.toolbar.additionalTrailingItems = [.init(barButtonSystemItem: .camera, target: self, action: #selector(cameraAction))]
        textField.iq.addToolbar(target: self,
                                previousConfiguration: nil,
                                nextConfiguration: .init(title: "Next", action: #selector(doneAction)),
                                rightConfiguration: .init(title: "Finish", action: #selector(doneAction)),
                                title: "TextView 2")
```

Hide Placeholder
```swift
        textField1.iq.hidePlaceholder = true
```

Customized Placeholder
```swift
        textField1.iq.placeholder = "My Own Placeholder"
```

## Author

Iftekhar Qurashi hack.iftekhar@gmail.com

## License

IQKeyboardToolbar is available under the MIT license. See the LICENSE file for more info.
