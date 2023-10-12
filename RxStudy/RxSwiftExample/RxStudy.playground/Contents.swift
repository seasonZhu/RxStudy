import RxSwift
import RxCocoa
import NSObject_Rx

import SwiftUI

let disposeBag = DisposeBag()

let callback: (() -> Void) = {
    
}

func aFunction(arg: Any) {
    
}

var tuple: (Int, String) = (10, "season")
print(tuple)
print(tuple.0)
print(tuple.1)

tuple.0 = 20
tuple.1 = "soso"

print(tuple)
print(tuple.0)
print(tuple.1)

tuple = (30, "sola")
print(tuple)
print(tuple.0)
print(tuple.1)

var tuple1: (age: Int, name: String) = (10, "season")
print(tuple1.age)
print(tuple1.name)

typealias PersonInfo = (age: Int, name: String)
var tuple2: PersonInfo = (10, "season")
print(tuple2.age)
print(tuple2.name)

protocol Animal {
    
}

struct Person: Animal {
    let age: Int
    let name: String
}

extension Array where Element == Person {
    func printName() {
        map {
            print($0.name)
        }
    }
}

let p1 = Person(age: 10, name: "season")
let p2 = Person(age: 20, name: "soso")
let p3 = Person(age: 30, name: "sola")

[p1, p2, p3].printName()

[p1, p2, p3].map { $0.name }

let array2 = [p1, p2, p3]

for person in array2 where person.age == 20 {
    /// 做逻辑业务
}

let p = Person(age: 10, name: "season")
print(p.age)
print(p.name)

func example(num: NSNumber, nickName: String) -> Person {
    let person = Person(age: num.intValue, name: nickName)
    return person
}

func example1(num: NSNumber, nickName: String) -> PersonInfo {
    return (num.intValue, nickName)
}

func example2(num: NSNumber, nickName: String) -> PersonInfo {
    return (num.intValue, nickName)
}

let numbers: Observable<Int> = Observable.create { observer -> Disposable in
    print(Thread.current)
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
    .subscribe(on: ConcurrentDispatchQueueScheduler(qos: .userInitiated))
    .observe(on: MainScheduler.instance)

numbers.subscribe { event in
    print(Thread.current)
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


let observable1 = Observable.zip(Observable.just(0),
                                 Observable.just(1),
                                 Observable.just(2),
                                 Observable.just(3),
                                 Observable.just(4),
                                 Observable.just(5)
                                 )

observable1.subscribe { event in
    print(event)
}.disposed(by: disposeBag)

class CocaCola {}

let obs = Observable.just(CocaCola())

/// 定义一个继电器
let subject = PublishSubject<Int>()

/// 这里虽然是subscribeOn,但是实际上是生成序列的线程,命名是不是很奇葩
subject.subscribe(on: ConcurrentDispatchQueueScheduler(qos: .userInitiated))
/// 这里虽然是observeOn,但是实际是订阅所在的线程,就是观察者实现的线程
subject.observe(on: MainScheduler.instance)

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

let successObservable = Observable.just(())
let errorObservable = Observable<S>.error(S())
successObservable.materialize()
struct S: Error {}


func test() {
    let numbers: Observable<Int> = Observable.create { observer -> Disposable in
        print(Thread.current)
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
//        .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .userInitiated))
//        .observeOn(MainScheduler.instance)
    numbers.subscribe { event in
        print(Thread.current)
        print(event)
    }
}

func request() -> Single<Data> {
    return Single<Data>.create { single in
        print(Thread.current)
        do {
            let data = try Data(contentsOf: URL(string: "https://www.wanandroid.com/banner/json")!)
            single(.success(data))
        }catch {
            single(.failure(error))
        }
        return Disposables.create()
    }.subscribeOn(ConcurrentDispatchQueueScheduler(qos: .userInitiated)).observeOn(MainScheduler.instance)
}

func responseData() {
    request().subscribe { data in
        
        let string = String(data: data, encoding: .utf8)
        print(string)
        print(Thread.current)
        
    } onFailure: { _ in
        
    }.disposed(by: disposeBag)
}

array.map { e in
    print(e)
}

array.compactMap { e in
    print(e)
}

let towDArray = [
    [1, 2, 3],
    [4, 5, [6, 7]]
    ]

let oneDArray = towDArray.flatMap { $0 }
    
let finalArray = oneDArray.flatMap { $0 }

print(finalArray)

//let dict = ["one": 1, "two": 2, "three": 3, "another": ["four": 4]] as [String : Any]
//
//dict.map { (k, v) in
//
//}
//
//dict.compactMap { (k, v) in
//
//}
//
//dict.flatMap { <#(key: String, value: Any)#> in
//    <#code#>
//}
[1, 2, 3].map({ (i: Int) -> Int in return i * 2 })
[1, 2, 3].map({ i in return i * 2 } )
[1, 2, 3].map({ i in i * 2 })
[1, 2, 3].map({ $0 * 2 })
[1, 2, 3].map() { $0 * 2 }
[1, 2, 3].map{ $0 * 2 }

let s = ["1", "2", "3", "a"].flatMap { Int($0) }
print(s)


let someArray = [[1, 2, 3], [4, 5, 6]].flatMap { $0 }
print(someArray)

let anotherArray = [[1, 2, 3], [4, 5, [6, 7]]].flatMap { $0 }

print(anotherArray)

extension Array {
    func map<T>(_ transform: (Element) -> T) -> [T] {
        var newArray:[T] = []
        for element in self {
            let newElement = transform(element)
            newArray.append(newElement)
        }
        return newArray
    }
}

let name1 = Teacher().className
let name2 = Teacher().classNameWithoutNamespace
let name3 = Teacher.className
let name4 = Teacher.classNameWithoutNamespace

let name5 = Student().className
let name6 = Student().classNameWithoutNamespace
let name7 = Student.className
let name8 = Student.classNameWithoutNamespace

let name9 = Teacher().memoryAddress
let name10 = Student().memoryAddress

/// 注意这个bufferSize传入的值,传入的越多,说明可以保留该订阅值的数据也就越多
let replaySubject = ReplaySubject<String>.create(bufferSize: 0)
/// 可以无限缓存,订阅前的数据,但是你要清楚你缓存的数据是有穷的,否则内存都兜不住
let unlimitedReplaySubject = ReplaySubject<String>.createUnbounded()

replaySubject
  .subscribe { print("Subscription: 1 Event:", $0) }
  .disposed(by: disposeBag)

replaySubject.onNext("🐶")
replaySubject.onNext("🐱")

replaySubject
  .subscribe { print("Subscription: 2 Event:", $0) }
  .disposed(by: disposeBag)

replaySubject.onNext("🅰️")
replaySubject.onNext("🅱️")

@dynamicMemberLookup
struct JSON {
    private let value: Any
    
    init(_ value: Any) {
        self.value = value
    }
    
    subscript(dynamicMember member: String) -> JSON {
        if let dict = value as? [String: Any], let value = dict[member] {
            return JSON(value)
        } else {
            return JSON(NSNull())
        }
    }
    
    subscript(index: Int) -> JSON {
        if let array = value as? [Any], array.indices.contains(index) {
            return JSON(array[index])
        } else {
            return JSON(NSNull())
        }
    }
}

let json = JSON(["name": "Tom", "age": 20, "hobbies": ["reading", "swimming"]])
print(json.name) // 输出 "Tom"
print(json.age) // 输出 20
print(json.hobbies[1]) // 输出 "swimming"

