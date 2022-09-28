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

    var userNamePublisher: AnyPublisher<Bool, Never> {
        return $userName
            .receive(on: RunLoop.main)
            .map { $0.isNotEmpty }
            .eraseToAnyPublisher()
    }

    var passwordPublisher: AnyPublisher<Bool, Never> {
        return $password
            .receive(on: RunLoop.main)
            .map { $0.isNotEmpty }
            .eraseToAnyPublisher()
    }

    init() {
        Publishers
            .CombineLatest(userNamePublisher, passwordPublisher)
            .map { $0 && $1 }
            .receive(on: RunLoop.main)
            /// 使用assign是有要求的extension Publisher where Self.Failure == Never
            .assign(to: \.buttonEnable, on: self)
            .store(in: &cancellables)
        
        /// 这种sink与下面的assign是同一种意思
//        userNamePublisher
//            .sink { self.showUserNameError = !$0 }
//            .store(in: &cancellables)
        
        userNamePublisher
            .map { !$0 }
            .assign(to: \.showUserNameError, on: self)
            .store(in: &cancellables)
    
        passwordPublisher
            .map { !$0 }
            .assign(to: \.showPasswordError, on: self)
            .store(in: &cancellables)
    }

    func clear() {
        let _ = cancellables.map { $0.cancel() }
        cancellables.removeAll()
    }

    deinit {
        print("\(className)被销毁了")
        clear()
    }
}

extension LoginPageViewModel: TypeNameProtocol {}
