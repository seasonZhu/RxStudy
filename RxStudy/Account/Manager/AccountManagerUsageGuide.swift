//
//  AccountManagerUsageGuide.swift
//  RxStudy
//
//  Created by code optimization on 2026/2/10.
//  Copyright © 2026 season. All rights reserved.
//

import Foundation
import RxSwift

// MARK: - AccountManager 协议化使用指南

/*
 ## AccountManager 协议化说明

 ### 架构改进

 1. **协议抽象** - AccountManageable 协议定义了账户管理的标准接口
 2. **向后兼容** - AccountManager.shared 单例继续可用
 3. **依赖注入** - 支持注入自定义实现，便于单元测试

 ### 推荐使用方式

 #### 方式一：直接使用单例（现有代码无需修改）
 ```swift
 // 现有代码继续工作
 AccountManager.shared.isLoginRelay.subscribe { isLogin in
     print("登录状态: \(isLogin)")
 }
 AccountManager.shared.autoLogin()
 ```

 #### 方式二：使用协议类型（推荐，便于测试）
 ```swift
 // 通过协议访问
 let accountManager: AccountManageable = AccountServiceContainer.current
 accountManager.isLoginRelay.subscribe { isLogin in
     print("登录状态: \(isLogin)")
 }
 accountManager.autoLogin()
 ```

 #### 方式三：依赖注入（在ViewModel中使用）
 ```swift
 class MyViewModel: HasDisposeBag {
     private let accountManager: AccountManageable

     init(accountManager: AccountManageable = AccountServiceContainer.current) {
         self.accountManager = accountManager
     }

     func setupLogin() {
         accountManager.isLoginRelay
             .subscribe(onNext: { [weak self] isLogin in
                 self?.updateUI(isLogin: isLogin)
             })
             .disposed(by: disposeBag)
     }
 }
 ```

 ### 单元测试示例

 ```swift
 // Mock 实现
 class MockAccountManager: AccountManageable, HasDisposeBag {
     let networkIsReachableRelay = BehaviorRelay(value: true)
     let isLoginRelay = BehaviorRelay(value: false)
     let myCoinRelay = BehaviorRelay<CoinRank?>(value: nil)
     let myUnreadMessageCountRelay = BehaviorRelay<Int>(value: 0)
     let isGrayModeRelay = BehaviorRelay(value: false)
     var layoutType: LayoutType = .wrap

     var username: String?
     var password: String?
     private(set) var accountInfo: AccountInfo?
     var cookieHeaderValue: String = ""

     private(set) var loginCalled = false
     private(set) var logoutCalled = false

     func autoLogin() {
         loginCalled = true
         isLoginRelay.accept(true)
     }

     func login(username: String, password: String, showLoading: Bool) {
         loginCalled = true
     }

     func optimizeLogin(username: String, password: String, showLoading: Bool, completion: (() -> Void)?) {
         loginCalled = true
         isLoginRelay.accept(true)
         completion?()
     }

     func saveLoginUsernameAndPassword(info: AccountInfo?, username: String, password: String) {
         self.username = username
         self.password = password
         self.accountInfo = info
         isLoginRelay.accept(true)
     }

     func saveFlutterLoginUsernameAndPassword(info: AccountInfo?, username: String, password: String) {
         self.username = username
         self.password = password
         self.accountInfo = info
         isLoginRelay.accept(true)
     }

     func clearAccountInfo() {
         logoutCalled = true
         isLoginRelay.accept(false)
         accountInfo = nil
     }

     func updateCollectIds(_ collectIds: [Int]) {
         accountInfo?.collectIds = collectIds
     }
 }

 // 测试用例
 class MyViewModelTests: XCTestCase {
     var mockManager: MockAccountManager!
     var viewModel: MyViewModel!

     override func setUp() {
         super.setUp()
         mockManager = MockAccountManager()
         AccountServiceContainer.set(mockManager)
         viewModel = MyViewModel(accountManager: mockManager)
     }

     override func tearDown() {
         AccountServiceContainer.reset()
         super.tearDown()
     }

     func testLogin() {
         // Given
         XCTAssertFalse(mockManager.isLoginRelay.value)

         // When
         viewModel.login()

         // Then
         XCTAssertTrue(mockManager.loginCalled)
         XCTAssertTrue(mockManager.isLoginRelay.value)
     }
 }
 ```

 ### 优势

 - ✅ 可测试性：可注入Mock实现
 - ✅ 解耦：代码依赖协议而非具体实现
 - ✅ 向后兼容：现有代码无需修改
 - ✅ 灵活性：支持多种实现方式

 ### 注意事项

 - 对于现有代码，继续使用 `AccountManager.shared` 即可
 - 新代码可以选择使用协议类型 `AccountManageable`
 - 单元测试时使用 `AccountServiceContainer.set()` 注入Mock
 */
