import RxSwift

let disposeBag = DisposeBag()

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


let array = [0, 1, 2, 3, 4, 5]
array.forEach { element in
    print(element)
}

let observable = Observable.from([0, 1, 2, 3, 4, 5])

observable.subscribe { (event: Event<Int>) in
    switch event {
    case .next(let some):
        print(some)
    case .error(let error):
        print(error)
    case .completed:
        print(event.debugDescription)
    }
}.disposed(by: disposeBag)


let observable1 = Observable.zip(Observable.just(0), Observable.just(1), Observable.just(2), Observable.just(3), Observable.just(4), Observable.just(5))

observable1.subscribe { event in
    print(event)
}.disposed(by: disposeBag)

class CocaCola {}

let obs = Observable.just(CocaCola())
