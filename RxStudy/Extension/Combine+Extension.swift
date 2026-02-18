//
//  Combine+Extension.swift
//  RxStudy
//
//  Created by dy on 2022/10/17.
//  Copyright © 2022 season. All rights reserved.
//

import Combine

extension Publisher {
    /// 这个并有什么用
    func weakSubscribe<S>(_ subject: S) -> AnyCancellable where S: Subject, Self.Failure == Never, Self.Failure == S.Failure, Self.Output == S.Output {
        return sink { [weak subject] value in
            subject?.send(value)
        }
    }
}

extension Publisher {

    func sink(event: @escaping ((CombineSinkEvent<Self.Output, Self.Failure>) -> Void)) -> AnyCancellable {
        return sink { completion in
            switch completion {
            case .finished:
                event(.completed)
            case .failure(let error):
                event(.error(error))
            }
        } receiveValue: { output in
            event(.next(output))
        }
    }
    
    func sink(onNext: ((Self.Output) -> Void)? = nil, onError: ((Self.Failure) -> Void)? = nil, onCompleted: (() -> Void)? = nil) -> AnyCancellable {
        return sink { completion in
            switch completion {
            case .finished:
                onCompleted?()
            case .failure(let error):
                onError?(error)
            }
        } receiveValue: { output in
            onNext?(output)
        }
    }
}
