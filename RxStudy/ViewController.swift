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

class ViewController: BaseViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "RxSwift"
        
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: 200, height: 44)
        button.setTitle("去积分排名页面", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.center = view.center
        view.addSubview(button)
        
        
        button.rx.tap.subscribe { [weak self] _ in
            self?.navigationController?.pushViewController(TabsController(type: .project), animated: true)
        }.disposed(by: disposeBag)
    }
    
    private func requestTest() {
        homeProvider.rx.request(HomeService.banner)
            .map(BaseModel<[Banner]>.self)
            .map { $0.data }
            .subscribe { model in
            print(model)
        } onError: { error in
            
        }
        
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
}

