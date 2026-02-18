//
//  TabAble.swift
//  RxStudy
//
//  Created by dy on 2022/6/24.
//  Copyright © 2022 season. All rights reserved.
//

import Foundation

protocol TabAble {
    
    associatedtype T: TabAble & Codable
    
    var children: [T]? { get }
    var courseId: Int? { get }
    var id: Int? { get }
    var name: String? { get }
    var order: Int? { get }
    var parentChapterId: Int? { get }
    var userControlSetTop: Bool? { get }
    var visible: Int? { get }
}
