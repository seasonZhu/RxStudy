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

@MainActor
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
                    DispatchQueue.main.async {
                        callback(.success(void))
                    }
                }
                
                request.endAccessingResources()
            }
        }
    }

    enum APIKeys {
        
        static nonisolated(unsafe) fileprivate(set) var storage = [String: String]()
    
        static let myServiceXKey = storage["MyServiceX"] ?? ""
    
        nonisolated(unsafe) static var myServiceYKey = storage["MyServiceY"] ?? ""
  }
}

/// 这里使用的方案五
/**
 这个文件（RxStudyKeys.m）没有使用标准的加解密算法，而是采用了一种简单的“混淆”方式来隐藏密钥内容。具体做法如下：

 密钥内容被编码为一组索引，这些索引指向一个很长的字符串（RxStudyKeysData）。
 通过索引取字符，将这些字符拼接成 C 字符串（tEST_KEYCString），最后再转换为 NSString。
 这种方式只是让密钥不直接明文出现在代码中，但并没有加密，只要有源码就能还原出密钥。
 总结：
 这不是加密算法，只是字符串混淆（obfuscation）。
 没有用到如 AES、DES、RSA 等加解密算法。
 这种方式的安全性有限，主要目的是防止密钥被直接搜索到，而不是防止逆向工程。
 
 */

import Keys

let testKey = RxStudyKeys().tEST_KEY
