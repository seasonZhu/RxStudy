//
//  BaseRequestable.swift
//  RxStudy
//
//  Created by dy on 2025/4/16.
//  Copyright © 2025 season. All rights reserved.
//

import Foundation

import RxSwift
import Moya
// Moya 14.x 自带 RxSwift 支持

/**
 为什么会出现这样一个层?
 我在做项目开发的时候,遇到了这样两个页面:
 A页面是一个关注列表页面,有列表接口与关注与取消关注接口
 B页面是一个他人主页页面,有他人信息接口与关注与取消关注接口
 
 可以看到,这两个页面都会用到关注与取消关注接口
 
 一个ViewController会对应一个ViewModel,而ViewModel可能会对应多个网络请求
 如果我们项目简单,直接多个网络请求放在一个ViewModel中,没有问题
 但是随着项目的复杂度增加,我们可能会遇到这样的问题:ViewModel中有多个网络请求,而其中某个或者某个网络请求可能会在多个ViewModel中复用
 有人可能会思考,那么就将业务复用接口写到一个基类ViewModel中继承即可
 但是Swift是单继承关系
 
 于是突破口就到了protocol,protocol可以多继承,而且protocol可以被多个类遵循,这样的话,我只需要将每个一个接口都通过protocol来定义与实现,那么就可以非常灵活的组装到ViewModel中
 
 于是我先定义了一个空协议BaseRequestable,然后每个网络请求都定义一个协议,并且继承BaseRequestable协议,并在extension中进行实现
 而后在ViewModel直接继承即可,调用即可
 
 这样做的好处是:
 1. 可以将网络请求与ViewModel进行解耦
 2. 可以将网络请求进行复用
 3. 可以将网络请求进行组合
 4. 可以将网络请求进行分层
 5. 可以将网络请求进行单元测试
 6. 可以将网络请求进行Mock
 
 同时,我也在考虑请求返回的类型,是否需要进行转换操作?
 考虑再三,我理解,网络请求就是一个单一的功能,返回数据即可,而涉及的转换,判断都不应该在这一层进行处理,所以最后返回的结果就是Single<Moya.Response>或者Moya.Response即可
                                
 
 */
protocol BaseRequestable {}

protocol HotKeyRequest: BaseRequestable {
    func requestHotKey() -> Single<Moya.Response>
}

extension HotKeyRequest {
    func requestHotKey() -> Single<Moya.Response> {
        homeProvider.rx.request(HomeService.hotKey)
    }
}

/**
 这里是一个协议,用来定义所有请求的接口,或者不通过协议,直接将请求写在一个enum中也可以
 之后ViewModel就按需通过这个Repository去调用自己想要的接口即可
 这样的好处是所有的接口都集中管理在一个类中,同时也可以通过extension来进行分组,也便于管理
 这样就可以每个接口都写一个Protocol,然后通过组合的方式继承到ViewModel
 保留了上面思路优点的同时,减少了不必要的代码量
 当然这种思路,其实在前端的网络请求中,还有如Android的Retrofit中也很常见
 */

protocol RepositoryProtocol {
    static func requestHotKey() -> Single<Moya.Response>
    
    static func requestBanner() -> Single<Moya.Response>
}

extension RepositoryProtocol {
    static func requestHotKey() -> Single<Moya.Response> {
        homeProvider.rx.request(HomeService.hotKey)
    }

    static func requestBanner() -> Single<Moya.Response> {
        homeProvider.rx.request(HomeService.banner)
    }
}

enum Repository: RepositoryProtocol {
    
}
