//
//  UIApplication+Extension.swift
//  RxStudy
//
//  Created by dy on 2025/9/17.
//  Copyright © 2025 season. All rights reserved.
//

import UIKit

extension UIApplication {
    static var appDelegate: AppDelegate? { UIApplication.shared.delegate as? AppDelegate }
    
    var  mainWindow: UIWindow? {
        if #available(iOS 13.0, *) {
            if let keyWindow = UIApplication.shared.connectedScenes
                .filter({ $0.activationState == .foregroundActive })
                .compactMap({ $0 as? UIWindowScene })
                .first?.windows
                .first(where: { $0.isKeyWindow }) {
                return keyWindow
            } else {
                return UIApplication.shared.delegate?.window ?? nil
            }
        } else {
            if UIApplication.shared.windows.last?.isKind(of: UIWindow.self) == false {
                return nil
            }
            return UIApplication.shared.keyWindow
        }
    }
}
