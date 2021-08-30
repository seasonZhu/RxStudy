import RxSwift
import RxCocoa
import NSObject_Rx

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

/// 定义一个继电器
let subject = PublishSubject<Int>()

/// 消费生产的序列
subject.subscribe { (event: Event<Int>) in
    switch event {
    case .next(let some):
        print(some + some)
    case .error(let error):
        print(error)
    case .completed:
        print(event.debugDescription)
    }
}.disposed(by: disposeBag)

observable.bind(to: subject)

/// 产生序列
subject.onNext(6)
subject.onNext(7)
subject.onNext(8)
subject.onNext(9)
subject.onNext(10)


let newArray = array.map { "\($0)" }

let newObservable = observable.map { "\($0)" }

//MARK:- 测试代码
private func requestTest() {
    homeProvider.rx.request(HomeService.banner)
        .map(BaseModel<[Banner]>.self)
        .map { $0.data }
        .subscribe { model in
        print(model)
    } onError: { error in
        
    }.disposed(by: disposeBag)
    
    let model1 = try? homeProvider.rx.request(HomeService.banner).map(BaseModel<[Banner]>.self).toBlocking().first()
    let model2 = try? homeProvider.rx.request(HomeService.topArticle).map(BaseModel<[Info]>.self).toBlocking().first()
    let model3 = try? homeProvider.rx.request(HomeService.normalArticle(0)).map(BaseModel<Page<Info>>.self).toBlocking().first()
    print("toBlocking")
    print(model1)
    print("----------------")
    print(model2)
    print("----------------")
    print(model3)
    print("----------------")
    
    myProvider.rx.request(MyService.coinRank(1)).map(BaseModel<Page<CoinRank>>.self).subscribe(onSuccess: { model in
        print(model)
    }, onError: { error in
        print(error)
    }).disposed(by: disposeBag)
}

private func createObservable() {
        
        let subject = PublishSubject<Void>()
        
        /// 使用flatMap转换为其他序列
        let otherOb =  subject.asObservable()
            .flatMapLatest({_ -> Observable<String> in
                print("flatMap")
                return netRequest()
            })
        
        // 发出一次next, 由于没有订阅，所以没有效
        subject.onNext(())
        
        // 订阅
        subject.subscribe(onNext: { (_) in
            print("发出一次事件")})
            .disposed(by: disposeBag)
        // 又发出一次事件
        subject.onNext(())
        
        // 订阅otherOb， 之后发出的事件都可以监听，除非序列发出Error事件
        otherOb.subscribe(onNext: { (value) in
            print("otherSub subscribe")
            print(value)})
            .disposed(by: disposeBag)
        
        // subject 发出两次事件
        subject.onNext(()) // [1]如果在netRequet方法中抛出Error, 就会引起序列终止，下面一个发出事件也就无效。
        subject.onNext(())

    }
    
// 模拟网络请求
private func netRequest() -> Observable<String> {
   return Observable<String>.create { (observer) -> Disposable in
    observer.onError(NSError(domain: "www.baidu.com", code: 30, userInfo: [:]))
//            observer.onNext("你好")
//            observer.onCompleted()
        return Disposables.create()
    }
}
