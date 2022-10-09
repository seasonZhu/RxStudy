//
//  AppState.swift
//  RxStudy
//
//  Created by dy on 2022/10/9.
//  Copyright © 2022 season. All rights reserved.
//

import Combine

class AppState: ObservableObject {
    @Published var isBack: Bool = false
}
