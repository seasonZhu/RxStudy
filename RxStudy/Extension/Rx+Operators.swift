//
//  Operators.swift
//  RxExample
//
//  Created by Krunoslav Zaher on 12/6/15.
//  Copyright © 2015 Krunoslav Zaher. All rights reserved.
//  Rx的双向绑定运算符,并没有实战,是从RxSwift的源码中的RxExample中拿过来的

import RxSwift
import RxCocoa
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

// Two way binding operator between control property and relay, that's all it takes.

infix operator <-> : DefaultPrecedence

#if os(iOS)
func nonMarkedText(_ textInput: UITextInput) -> String? {
    let start = textInput.beginningOfDocument
    let end = textInput.endOfDocument

    guard let rangeAll = textInput.textRange(from: start, to: end),
        let text = textInput.text(in: rangeAll) else {
            return nil
    }

    guard let markedTextRange = textInput.markedTextRange else {
        return text
    }

    guard let startRange = textInput.textRange(from: start, to: markedTextRange.start),
        let endRange = textInput.textRange(from: markedTextRange.end, to: end) else {
        return text
    }

    return (textInput.text(in: startRange) ?? "") + (textInput.text(in: endRange) ?? "")
}

func <-> <Base>(textInput: TextInput<Base>, relay: BehaviorRelay<String>) -> Disposable {
    let bindToUIDisposable = relay.bind(to: textInput.text)

    let bindToRelay = textInput.text
        .subscribe(onNext: { [weak base = textInput.base] n in
            guard let base = base else {
                return
            }

            let nonMarkedTextValue = nonMarkedText(base)

            /**
             In some cases `textInput.textRangeFromPosition(start, toPosition: end)` will return nil even though the underlying
             value is not nil. This appears to be an Apple bug. If it's not, and we are doing something wrong, please let us know.
             The can be reproed easily if replace bottom code with 
             
             if nonMarkedTextValue != relay.value {
                relay.accept(nonMarkedTextValue ?? "")
             }

             and you hit "Done" button on keyboard.
             */
            if let nonMarkedTextValue = nonMarkedTextValue, nonMarkedTextValue != relay.value {
                relay.accept(nonMarkedTextValue)
            }
        }, onCompleted:  {
            bindToUIDisposable.dispose()
        })

    return Disposables.create(bindToUIDisposable, bindToRelay)
}
#endif

func <-> <T>(property: ControlProperty<T>, relay: BehaviorRelay<T>) -> Disposable {
    if T.self == String.self {
#if DEBUG && !os(macOS)
        fatalError("It is ok to delete this message, but this is here to warn that you are maybe trying to bind to some `rx.text` property directly to relay.\n" +
            "That will usually work ok, but for some languages that use IME, that simplistic method could cause unexpected issues because it will return intermediate results while text is being inputed.\n" +
            "REMEDY: Just use `textField <-> relay` instead of `textField.rx.text <-> relay`.\n" +
            "Find out more here: https://github.com/ReactiveX/RxSwift/issues/649\n"
            )
#endif
    }

    let bindToUIDisposable = relay.bind(to: property)
    let bindToRelay = property
        .subscribe(onNext: { n in
            relay.accept(n)
        }, onCompleted:  {
            bindToUIDisposable.dispose()
        })

    return Disposables.create(bindToUIDisposable, bindToRelay)
}

import RxRelay

/// RxCocoa's BehaviorRelay replays the most recent value provided to it for each of the subscribed observers. It is created with an initial value, has wrappedValue property to access the current value and a projectedValue to expose a projection providing API to subscribe a new observer: (Thanks to Adrian Zubarev for pointing this out)
/// Combine's Published property wrapper is similar in spirit, allowing clients to subscribe to @Published properties (via the $ projection) to receive updates when the value changes.
@propertyWrapper
class RxBehaviorRelay<T> {
    var wrappedValue: T {
        set {
            projectedValue.accept(newValue)
        }
        
        get {
            projectedValue.value
        }
    }
    
    var projectedValue: BehaviorRelay<T>
    
    init(wrappedValue: T) {
        self.projectedValue = BehaviorRelay(value: wrappedValue)
        self.wrappedValue = wrappedValue
    }
}
