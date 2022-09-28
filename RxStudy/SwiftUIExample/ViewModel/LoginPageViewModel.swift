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

    var userNamePublisher: AnyPublisher<String, Never> {
        return $userName
            .receive(on: RunLoop.main)
            .map { value in
                guard value.count > 2 else {
                    self.showUserNameError = value.count > 0
                    return ""
                }
                self.showUserNameError = false
                return value
            }
            .eraseToAnyPublisher()
    }

    var passwordPublisher: AnyPublisher<String, Never> {
        return $password
            .receive(on: RunLoop.main)
            .map { value in
                guard value.count > 5 else {
                    self.showPasswordError = value.count > 0
                    return ""
                }
                self.showPasswordError = false
                return value
            }
            .eraseToAnyPublisher()
    }

    init() {
        Publishers
            .CombineLatest(userNamePublisher, passwordPublisher)
            .map { v1, v2 in
                !v1.isEmpty && !v2.isEmpty
            }
            .receive(on: RunLoop.main)
            /// 使用assign是有要求的extension Publisher where Self.Failure == Never
            .assign(to: \.buttonEnable, on: self)
            .store(in: &cancellables)
    }

    func clear() {
        let _ = cancellables.map { $0.cancel() }
        cancellables.removeAll()
    }

    deinit {
        clear()
    }
}

