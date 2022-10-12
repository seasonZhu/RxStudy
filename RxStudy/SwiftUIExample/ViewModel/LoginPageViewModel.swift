//
//  LoginPageViewModel.swift
//  RxStudy
//
//  Created by dy on 2022/9/28.
//  Copyright © 2022 season. All rights reserved.
//

import Foundation
import Combine

class LoginPageViewModel: ObservableObject {
    
    @Published var userName: String = ""
    
    @Published var password: String = ""
    
    @Published var buttonEnable = false

    @Published var showUserNameError = false
    
    @Published var showPasswordError = false

    var cancellables = Set<AnyCancellable>()
    
    var usernameValid = PassthroughSubject<Bool, Never>()

    var passwordValid = PassthroughSubject<Bool, Never>()

    init() {
        
        $userName
            .map { $0.isNotEmpty }
            .subscribe(usernameValid)
            .store(in: &cancellables)
        
        $password
            .map { $0.isNotEmpty }
            .subscribe(passwordValid)
            .store(in: &cancellables)
        
        usernameValid
            .map { !$0 }
            .assign(to: \.showUserNameError, on: self)
            .store(in: &cancellables)
    
        passwordValid
            .map { !$0 }
            .assign(to: \.showPasswordError, on: self)
            .store(in: &cancellables)
        
        Publishers
            .CombineLatest(usernameValid, passwordValid)
            .map { $0 && $1 }
            /// 使用assign是有要求的extension Publisher where Self.Failure == Never
            .assign(to: \.buttonEnable, on: self)
            .store(in: &cancellables)
    }
    
    private func clear() {
        let _ = cancellables.map { $0.cancel() }
        cancellables.removeAll()
    }

    deinit {
        print("\(className)被销毁了")
        clear()
    }
}

extension LoginPageViewModel {
    func startListenUserNameInput() {
        $userName
            .map { $0.isNotEmpty }
            .subscribe(usernameValid)
            .store(in: &cancellables)
    }
    
    func startListenPasswordInput() {
        $password
            .map { $0.isNotEmpty }
            .subscribe(passwordValid)
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
