//
//  UIKitBridgeSwiftUI.swift
//  RxStudy
//
//  Created by dy on 2023/6/1.
//  Copyright © 2023 season. All rights reserved.
//

import UIKit
import SwiftUI

extension UIViewController {
    
    private struct Preview: UIViewControllerRepresentable {

        let viewController: UIViewController
        
        func makeUIViewController(context: Context) -> UIViewController {
            return viewController
        }
        
        func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
    }
    
    func showPreview() -> some View {
        Preview(viewController: self)
    }
}

extension UIView {
    
    private struct Preview: UIViewRepresentable {
        
        typealias UIViewType = UIView
        
        let view: UIView
        
        func makeUIView(context: Context) -> UIView {
            return view
        }
        
        func updateUIView(_ uiView: UIView, context: Context) {}
    }
    

    func showPreview() -> some View {
        Preview(view: self)
    }
}
