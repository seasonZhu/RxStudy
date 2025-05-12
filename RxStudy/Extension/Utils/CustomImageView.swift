//
//  DebugImageView.swift
//  RxStudy
//
//  Created by dy on 2024/8/20.
//  Copyright © 2024 season. All rights reserved.
//

// iOS平台中有效管理图像资源的5种策略
// https://levelup.gitconnected.com/5-effective-strategies-for-managing-image-resources-in-ios-45681f475461

import Foundation

final class CustomImageView: UIImageView {
    
    var warning: UIImageView?
    
    var blurBackground: UIVisualEffectView?
    
    override var image: UIImage? {
        didSet {
            super.image = image

            // If in Debug and the image is too big, show a warning on top of the image view.
#if DEBUG
            if isImageTooLarge {
                if warning != nil { return }
                let blurBackground = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
                blurBackground.translatesAutoresizingMaskIntoConstraints = false
                blurBackground.alpha = 0.7
                addSubview(blurBackground)
                NSLayoutConstraint.activate([
                    blurBackground.leftAnchor.constraint(equalTo: leftAnchor),
                    blurBackground.topAnchor.constraint(equalTo: topAnchor),
                    blurBackground.rightAnchor.constraint(equalTo: rightAnchor),
                    blurBackground.bottomAnchor.constraint(equalTo: bottomAnchor)
                ])
                self.blurBackground = blurBackground
                
                let warning = UIImageView(image: UIImage(systemName: "exclamationmark.triangle"))
                warning.tintColor = .red
                warning.translatesAutoresizingMaskIntoConstraints = false
                addSubview(warning)
                NSLayoutConstraint.activate([
                    warning.centerXAnchor.constraint(equalTo: centerXAnchor),
                    warning.centerYAnchor.constraint(equalTo: centerYAnchor)
                ])
                self.warning = warning
            } else {
                warning?.removeFromSuperview()
                warning = nil
                
                blurBackground?.removeFromSuperview()
                blurBackground = nil
            }
#endif
        }
    }
    
    // Check if the image is bigger than the image view's frame
    private var isImageTooLarge: Bool {
        guard let image = image else { return false }
        return image.size.height * image.size.width > self.frame.height * self.frame.width
    }
}
