//
//  KeyConstants.swift
//  RxStudy
//
//  Created by dy on 2025/5/20.
//  Copyright © 2025 season. All rights reserved.
//

import Foundation

/// 一个行业难题，如何拯救你的API密钥：iOS中隐藏敏感信息的最佳方案
/// https://mp.weixin.qq.com/s/uRRDFTg8K8yGc9ef1oYaPw
/// 这里使用的方案三

enum KeyConstants {
    
    static func loadAPIKeys(callback: @escaping ((Result<Void, Error>) -> Void)) {
        
        let request = NSBundleResourceRequest(tags: ["APIKeys"])
        
        request.beginAccessingResources { error in
            if let error {
                callback(.failure(error))
                request.endAccessingResources()
            } else {
                let url = Bundle.main.url(forResource: "APIKeys", withExtension: "json")!
                
                if let data = try? Data(contentsOf: url),
                   let dict =  try? JSONDecoder().decode([String: String].self, from: data) {
                    
                    APIKeys.storage = dict
                    callback(.success(void))
                }
                
                request.endAccessingResources()
            }
        }
    }

    enum APIKeys {
        
        static fileprivate(set) var storage = [String: String]()
    
        static let myServiceXKey = storage["MyServiceX"] ?? ""
    
        static var myServiceYKey = storage["MyServiceY"] ?? ""
  }
}

/// 这里使用的方案五

import Keys

let testKey = RxStudyKeys().tEST_KEY
