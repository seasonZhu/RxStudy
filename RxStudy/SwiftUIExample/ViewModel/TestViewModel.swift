//
//  TestViewModel.swift
//  RxStudy
//
//  Created by dy on 2022/10/10.
//  Copyright © 2022 season. All rights reserved.
//

import Combine

import RxStudyUtils

class TestViewModel {
    
    private var cancellables = Set<AnyCancellable>()
    
    private func clear() {
        let _ = cancellables.map { $0.cancel() }
        cancellables.removeAll()
    }
    
    func test() {
        a()
        b()
        c()
    }
    
    deinit {
        print("\(className)被销毁了")
        clear()
    }
}

extension TestViewModel: TypeNameProtocol {}

extension TestViewModel {
    func a() {
        print(#function)
        let publisher = PassthroughSubject<Int, Never>()
        publisher.send(1)
        publisher.send(2)
        publisher.send(completion: .finished)
        
        print("开始订阅")
        
        publisher.sink(
            receiveCompletion: { complete in
                print(complete)
            },
            receiveValue: { value in
                print(value)
        
            })
        .store(in: &cancellables)
        
        publisher.send(3)
        publisher.send(completion: .finished)
    }
    
    func b() {
        print(#function)
        let publisher = CurrentValueSubject<Int, Never>(0)

        publisher.value = 1
        publisher.value = 2
        publisher.send(completion: .finished)

        print("开始订阅")

        publisher.sink(
            receiveCompletion: { complete in
                print(complete)
            },
            receiveValue: { value in
                print(value)
            })
        .store(in: &cancellables)
    }
    
    func c() {
        print(#function)
        
        let publisher = CurrentValueSubject<Int, Never>(0)
        print("开始订阅")
        publisher.sink(
            receiveCompletion: { complete in
                print(complete)
            },
            receiveValue: { value in
                print(value)
            })
        .store(in: &cancellables)
        
        publisher.value = 1
        publisher.value = 2
        publisher.send(3)
        publisher.send(completion: .finished)
        print("--- \(publisher.value) ---")
    }
}

/**
 a()
 开始订阅
 finished
 b()
 开始订阅
 finished
 c()
 开始订阅
 0
 1
 2
 3
 finished
 --- 3 ---
 */
