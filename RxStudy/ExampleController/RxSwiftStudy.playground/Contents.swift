import RxSwift

var greeting = "Hello, playground"

let numbers: Observable<Int> = Observable.create { observer -> Disposable in

    observer.onNext(0)
    observer.onNext(1)
    observer.onNext(2)
    observer.onNext(3)
    observer.onNext(4)
    observer.onNext(5)
    observer.onNext(6)
    observer.onNext(7)
    observer.onNext(8)
    observer.onNext(9)
    observer.onCompleted()

    return Disposables.create()
}

numbers.subscribe { event in
    print(event)
}
