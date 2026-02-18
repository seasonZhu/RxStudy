//
//  PollingNetworkRequester.swift
//  RxStudy
//
//  Created by dy on 2025/6/4.
//  Copyright © 2025 season. All rights reserved.
//

import Foundation

import RxSwift
import SVProgressHUD

import Moya

enum PollingEndReason {
    case success(Moya.Response)
    case failure(Error)
    case timeout
}

class PollingNetworkRequester {
    private let interval: RxTimeInterval
    
    private let maxPollingTime: RxTimeInterval
    
    private let scheduler: SchedulerType
    
    private let requestClosure: () -> Single<Moya.Response>
    
    private var disposeBag = DisposeBag()

    private let trigger = PublishSubject<Void>()

    /// 轮询结束回调
    var onPollingEnd: ((PollingEndReason) -> Void)?

    init(
        interval: RxTimeInterval,
        maxPollingTime: RxTimeInterval,
        scheduler: SchedulerType = MainScheduler.instance,
        requestClosure: @escaping () -> Single<Moya.Response>
    ) {
        self.interval = interval
        self.maxPollingTime = maxPollingTime
        self.scheduler = scheduler
        self.requestClosure = requestClosure
    }

    func startListening() {
        disposeBag = DisposeBag()

        trigger
            .concatMap { [weak self] _ -> Observable<PollingEndReason> in
                guard let self = self else { return Observable.empty() }
                return self.pollingObservable()
            }
            .observe(on: scheduler)
            .subscribe(onNext: { [weak self] reason in
                self?.onPollingEnd?(reason)
            })
            .disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(UIApplication.didEnterBackgroundNotification).subscribe(onNext: { [weak self] _ in
            self?.stop()
        }).disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(UIApplication.willEnterForegroundNotification).subscribe(onNext: { [weak self] _ in
            self?.trigger.onNext(())
        }).disposed(by: disposeBag)
    }
    
    func action() {
        trigger.onNext(())
    }
    
    func stop() {
        SVProgressHUD.dismiss()
        disposeBag = DisposeBag()
    }

    private func pollingObservable() -> Observable<PollingEndReason> {
        SVProgressHUD.setDefaultMaskType(.black)
        SVProgressHUD.show()

        // 用 PublishSubject 作为事件出口
        let resultSubject = PublishSubject<PollingEndReason>()
        var isEnded = false

        let polling = Observable<Int>.interval(interval, scheduler: scheduler)
            .flatMapLatest { [weak self] (_: Int) -> Observable<PollingEndReason> in
                guard let self = self else { return Observable.empty() }
                return self.requestClosure()
                    .asObservable()
                    .flatMap { response -> Observable<PollingEndReason> in
                        if response.statusCode == 200 {
                            return Observable.just(.success(response))
                        } else {
                            // 状态码不是200，继续轮询
                            return Observable.empty()
                        }
                    }
                    .catch { error in
                        Observable.just(.failure(error))
                    }
            }
            .take(1)
            .do(onNext: { reason in
                if !isEnded {
                    isEnded = true
                    resultSubject.onNext(reason)
                    resultSubject.onCompleted()
                }
            })

        let timeout = Observable<Void>.just(())
            .delay(maxPollingTime, scheduler: scheduler)
            .map { _ in .timeout }
            .do(onNext: { reason in
                if !isEnded {
                    isEnded = true
                    resultSubject.onNext(reason)
                    resultSubject.onCompleted()
                }
            })

        Observable.amb([polling, timeout])
            .subscribe(onNext: { reason in
                if !isEnded {
                    isEnded = true
                    resultSubject.onNext(reason)
                    resultSubject.onCompleted()
                }
            })
            .disposed(by: disposeBag)

        return resultSubject
            .do(onDispose: {
                SVProgressHUD.dismiss()
            })
    }
}
