//
//  LoginPageViewModel.swift
//  RxStudy
//
//  Created by dy on 2022/9/28.
//  Copyright © 2022 season. All rights reserved.
//

import Foundation
import Combine
import CombineExt

import RxSwift
import RxRelay

class LoginPageViewModel: ObservableObject {
    
    @Published var userName: String = ""
    
    @Published var password: String = ""
    
    @Published var buttonEnable = false

    @Published var showUserNameError = false
    
    @Published var showPasswordError = false
    
    @Published var showAlert = false
    
    var usernameValid = PassthroughSubject<Bool, Never>()

    var passwordValid = PassthroughSubject<Bool, Never>()
    
    var cancellables = Set<AnyCancellable>()

    init() {
        
        $userName
        /// 去掉前两次监听,第一次初始化,第二次点击编辑准备输入
            .dropFirst(2)
            .map { $0.isNotEmpty }
        /// 说明assign(to: 这个如果只使用系统带入的语法非常容易导致循环引用,而不是这个subscribe导致的
            .subscribe(usernameValid)
            //.weakSubscribe(usernameValid)
            .store(in: &cancellables)
        
        $password
            .dropFirst(2)
            .map { $0.isNotEmpty }
            .subscribe(passwordValid)
            .store(in: &cancellables)
        
        usernameValid
            .map { !$0 }
            .assign(to: \.showUserNameError, on: self, ownership: .weak)
//            .sink(receiveValue: { [weak self] bool in
//                self?.showUserNameError = bool
//            })
            .store(in: &cancellables)
    
        passwordValid
            .map { !$0 }
            .assign(to: \.showPasswordError, on: self, ownership: .weak)
//            .sink(receiveValue: { [weak self] bool in
//                self?.showPasswordError = bool
//            })
            .store(in: &cancellables)
        
        Publishers
            .CombineLatest(usernameValid, passwordValid)
            .map { $0 && $1 }
            /// 使用assign是有要求的extension Publisher where Self.Failure == Never
            .assign(to: \.buttonEnable, on: self, ownership: .weak)
//            .sink(receiveValue: { [weak self] bool in
//                self?.buttonEnable = bool
//            })
            .store(in: &cancellables)
        
        aExample()
    }
    
    func clear() {
        let _ = cancellables.map { $0.cancel() }
        cancellables.removeAll()
    }

    deinit {
        print("\(className)被销毁了")
    }
}

extension LoginPageViewModel {
    private func aExample() {
        let sink = Subscribers.Sink<Bool, Never> { c in
            
        } receiveValue: { input in
            print("combine input:\(input)")
        }
        
        let assign = Subscribers.Assign(object: self, keyPath: \.showUserNameError)
        
        /// 一个继电器
        let relay = PassthroughSubject<Bool, Never>()
        
        /// 序列(继电器)把数据给继电器
        usernameValid.subscribe(relay).store(in: &cancellables)
        
        /// 序列(继电器)把数据给订阅者
        relay.receive(subscriber: sink)
        
        /// 而RxSwift只有一种写法,那就是subscribe,在RxCocoa中多了一种选择bind
        let behaviorRelay = BehaviorRelay(value: "")
        
        $userName.sink { value in
            behaviorRelay.subscribe { event in
                switch event {
                case .next(let value):
                    print("rx value:\(value)")
                case .error(_):
                    break
                case .completed:
                    break
                }
            }
            .dispose()
            
            Observable.just(value).bind(to: behaviorRelay).dispose()
        }
        .store(in: &cancellables)
        
    }
}

extension LoginPageViewModel: TypeNameProtocol {}


//MARK: -  CbBehaviorSubject
/// CbBehaviorSubject即CombineBehaviorSubject的缩写,本质上是封装CurrentValueSubject,它和RxSwift中的BehaviorSubject类似
@propertyWrapper
class CbBehaviorSubject<T> {
    var wrappedValue: T {
        set {
            projectedValue.value = newValue
        }
        
        get {
            projectedValue.value
        }
    }
    
    var projectedValue: CurrentValueSubject<T, Never>
    
    init(wrappedValue: T) {
        self.projectedValue = CurrentValueSubject(wrappedValue)
        self.wrappedValue = wrappedValue
    }
}
