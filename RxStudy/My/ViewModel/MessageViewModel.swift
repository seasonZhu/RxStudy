//
//  MessageViewModel.swift
//  RxStudy
//
//  Created by dy on 2022/6/27.
//  Copyright © 2022 season. All rights reserved.
//

import Foundation

func getReadMessageList() {
    myProvider.rx.request(MyService.readList(1))
        .map(BaseModel<Page<Message>>.self)
        .map{ $0.data }
        .compactMap{ $0 }
        .asObservable()
        .asSingle()
        .subscribe { event in
            switch event {
            case .success(let any):
                print(any)
            case .failure:
                break
            }
        }
}
