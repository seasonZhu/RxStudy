# IQKeyboardCore

[![CI Status](https://img.shields.io/travis/hackiftekhar/IQKeyboardCore.svg?style=flat)](https://travis-ci.org/hackiftekhar/IQKeyboardCore)
[![Version](https://img.shields.io/cocoapods/v/IQKeyboardCore.svg?style=flat)](https://cocoapods.org/pods/IQKeyboardCore)
[![License](https://img.shields.io/cocoapods/l/IQKeyboardCore.svg?style=flat)](https://cocoapods.org/pods/IQKeyboardCore)
[![Platform](https://img.shields.io/cocoapods/p/IQKeyboardCore.svg?style=flat)](https://cocoapods.org/pods/IQKeyboardCore)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

IQKeyboardCore is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'IQKeyboardCore'
```

## Usage

IQKeyboardCore is not intended to use independently. It's just a helper and extension for most of the IQKeyboard related libraries

This contains IQTextInputView protocol
```swift
@objc public protocol IQTextInputView where Self: UIView, Self: UITextInputTraits {
}
```
UITextField, UITextView and UISearchBar are the known classes who adopted this protocol within the library

```swift
@objc extension UITextField: IQTextInputView {...}

@objc extension UITextView: IQTextInputView {...}

@objc extension UISearchBar: IQTextInputView {...}
```

This library also contains IQEnableMode which is used by other libraries
```swift
@objc public enum IQEnableMode: Int {
    case `default`
    case enabled
    case disabled
}
```

There are other extension functions which are available on UIView
```swift
public extension IQKeyboardExtension where Base: UIView {
    func viewContainingController() -> UIViewController?
    func superviewOf<T: UIView>(type classType: T.Type, belowView: UIView? = nil) -> T?
    func textFieldSearchBar() -> UISearchBar?
    func isAlertViewTextField() -> Bool
}
```

Above extension functions can be used like below
```swift
  view.iq.viewContainingController()
  view.iq.superviewOf(type: UIScrollView.self)
  view.iq.textFieldSearchBar()
  view.iq.isAlertViewTextField()
```

## Author

hackiftekhar, ideviftekhar@gmail.com

## License

IQKeyboardCore is available under the MIT license. See the LICENSE file for more info.
