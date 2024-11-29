# IQTextView

[![CI Status](https://img.shields.io/travis/hackiftekhar/IQTextView.svg?style=flat)](https://travis-ci.org/hackiftekhar/IQTextView)
[![Version](https://img.shields.io/cocoapods/v/IQTextView.svg?style=flat)](https://cocoapods.org/pods/IQTextView)
[![License](https://img.shields.io/cocoapods/l/IQTextView.svg?style=flat)](https://cocoapods.org/pods/IQTextView)
[![Platform](https://img.shields.io/cocoapods/p/IQTextView.svg?style=flat)](https://cocoapods.org/pods/IQTextView)

![Screenshot](https://raw.githubusercontent.com/hackiftekhar/IQTextView/master/Screenshot/IQTextViewScreenshot.png)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

IQTextView is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'IQTextView'
```

## Usage

You can set any UITextView class to IQTextView and then you can change the placeholder and placeholderTextColor from the storyboard

To change them via code, you may have to set them programmatically
```swift
textView.placeholderTextColor = UIColor.lightGray
textView.placeholder = "Enter your message here..."
```

To work this with IQKeyboardToolbarManager to show placeholder in toolbar, you may have to confirm IQPlaceholderable manually in your code
```swift
@available(iOSApplicationExtension, unavailable)
@MainActor
extension IQTextView: IQPlaceholderable { }
```

## Author

Iftekhar Qurashi hack.iftekhar@gmail.com

## License

IQTextView is available under the MIT license. See the LICENSE file for more info.
