//
//  ViewController.swift
//  RxStudy
//
//  Created by season on 2019/1/29.
//  Copyright © 2019 season. All rights reserved.
//

import UIKit

import RxSwift
import RxCocoa
import RxBlocking
import Moya

class ViewController: UIViewController {
    
    var exampleListViewModel = ExampleListViewModel()
    
    var saveListViewModel: ExampleListViewModel!
    
    var tableView: UITableView!
    
    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "RxSwift"
        
        let buttonItem = UIBarButtonItem.init(title: "tableView", style: .plain, target: nil, action: nil)
        /// 使用rx进行绑定
        buttonItem.rx.tap.subscribe(onNext: { [weak self] in
            self?.tableViewShow()
        }).disposed(by: disposeBag)
        navigationItem.rightBarButtonItem = buttonItem
        
        tableView = UITableView(frame: view.bounds, style:.plain)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "exampleListCell")
        view.addSubview(tableView)
        
        saveListViewModel = exampleListViewModel
        
        //将数据源数据绑定到tableView上
        exampleListViewModel.data.bind(to: tableView.rx.items(cellIdentifier:"exampleListCell")) { _, example, cell in
                cell.textLabel?.text = "\(example.keys.first!)"
                cell.detailTextLabel?.text = example.values.first
        }.disposed(by: disposeBag)
        
        //tableView点击响应
        tableView.rx.modelSelected([Int: String].self).subscribe { example in
            self.tableViewHidden()
            
            switch example.element?.first?.key {
            case let x where x == 0:
                self.labelBind()
            case let x where x == 1:
                self.buttonIsEnableBind()
            case let x where x == 2:
                self.buttonRxUse()
            case let x where x == 3:
                self.textViewRxUse()
            default:
                print("按的位置")
            }
        }.disposed(by: disposeBag)
        
        let observable = Observable.of("A", "B", "C")
        
        observable
            .do(onNext: { element in
                print("Intercepted Next：", element)
            }, onError: { error in
                print("Intercepted Error：", error)
            }, onCompleted: {
                print("Intercepted Completed")
            }, onDispose: {
                print("Intercepted Disposed")
            })
            .subscribe(onNext: { element in
                print(element)
            }, onError: { error in
                print(error)
            }, onCompleted: {
                print("completed")
            }, onDisposed: {
                print("disposed")
            }).dispose()
        
        homeProvider.rx.request(HomeService.banner)
            .map(BaseModel<[Banner]>.self)
            .map { $0.data }
            .subscribe { model in
            print(model)
        } onError: { error in
            
        }
        
        do {
            let model = try homeProvider.rx.request(HomeService.banner).map(BaseModel<[Banner]>.self).toBlocking().first()
            print("toBlocking:\n\(model)")
        } catch {
            print(error)
        }

    }

    //MARK:- Rx用例
    
    //MARK:- 与UILabel绑定的例子
    func labelBind() {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
        label.center = view.center
        label.textAlignment = .center
        view.addSubview(label)
        
        //观察者
        let observer: Binder<String> = Binder(label) { (view, text) in
            //收到发出的索引数后显示到label上
            view.text = text
        }
        
        //Observable序列（每隔1秒钟发出一个索引数）
//        let observable = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
//        observable
//            .map { "当前索引数：\($0 )"}
//            .bind(to: observer)
//            .disposed(by: disposeBag)

        /// 自带就有很多的属性绑定
        let observable = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
        observable
            .map { "当前索引数：\($0 )"}
            .bind(to: label.rx.text) //收到发出的索引数后显示到label上
            .disposed(by: disposeBag)
        
        /// 自定义的绑定属性
        observable
            .map { CGFloat($0 * $0) }
            .bind(to: label.rx.fontSize) //根据索引数不断变放大字体
            .disposed(by: disposeBag)
    }
    
    func buttonIsEnableBind() {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
        button.center = view.center
        button.titleLabel?.textAlignment = .center
        button.setTitle("可以点击", for: .normal)
        button.setTitle("不可点击", for: .disabled)
        button.setTitleColor(UIColor.blue, for: .normal)
        button.setTitleColor(UIColor.lightGray, for: .disabled)
        view.addSubview(button)
        
        let observable = Observable<Int>.interval(1, scheduler: MainScheduler.instance)
        observable
            .map { $0 % 2 == 0 }
            .bind(to: button.rx.isEnabled)
            .disposed(by: disposeBag)
    }
    
    func buttonRxUse() {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 44))
        button.center = view.center
        button.titleLabel?.textAlignment = .center
        button.setTitle("按钮的点击事件", for: .normal)
        button.setTitleColor(.black, for: .normal)
        view.addSubview(button)
        
        button.rx.tap
            .subscribe(onNext: { (_) in
                print("点击了按钮")
            }, onError: { (error) in
                
            }, onCompleted: {
                
            }).disposed(by: disposeBag)
    }
    
    func textViewRxUse() {
        let textView = UITextView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 200))
        textView.center = view.center
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.black.cgColor
        view.addSubview(textView)
        
        textView.rx.text
            .map { (text) -> Bool in
                guard let string = text else {
                    return false
                }
                
                return string.count > 0
            }.subscribe(onNext: { (isTrue) in
                print("输入变化了")
            }, onError: { (error) in
                
            }, onCompleted: {
                print("输入结束") // 这个好像没有什么用呀
            }, onDisposed: {
                
            }).disposed(by: disposeBag)
    
    }

    func tableViewHidden() {
        tableView.isHidden = true
    }
    
    @objc
    func tableViewShow() {
        view.subviews.filter { $0 != self.tableView }.forEach { $0.removeFromSuperview() }
        tableView.isHidden = false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

struct ExampleListViewModel {
    let data = Observable.just([([0: "labelBind"]),
                                ([1: "buttonIsEnableBind"]),
                                ([2: "buttonRxUse"]),
                                ([3: "textViewRxUse"]),
                                ])
}

extension Reactive where Base: UILabel {
    public var fontSize: Binder<CGFloat> {
        return Binder(self.base) { label, fontSize in
            label.font = UIFont.systemFont(ofSize: fontSize)
        }
    }
}
