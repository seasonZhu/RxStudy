//
//  ContentScrollView.swift
//  RxStudy
//
//  Created by dy on 2023/6/16.
//  Copyright © 2023 season. All rights reserved.
//

import UIKit

class ContentScrollView: UIScrollView {
    
    let scrollDirection: ScrollDirection
    
    init(scrollDirection: ScrollDirection, frame: CGRect) {
        self.scrollDirection = scrollDirection
        super.init(frame: frame)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let count = realSubviewsCount()
        
        if subviews.count > count {
            switch scrollDirection {
            case .vertical:
                let width = frame.width
 
                guard let maxY = subviews[0...subviews.count - count].map({ $0.frame.maxY }).max() else {
                    return
                }
                
                contentSize = CGSize(width: width, height: maxY)
            case .horizontal:
                let height = frame.height
                
                guard let maxX = subviews[0...subviews.count - count].map({ $0.frame.maxX }).max() else {
                    return
                }
                
                contentSize = CGSize(width: maxX, height: height)
            case .both:
                guard let maxX = subviews[0...subviews.count - count].map({ $0.frame.maxX }).max(),
                      let maxY = subviews[0...subviews.count - count].map({ $0.frame.maxY }).max() else {
                    return
                }

                contentSize = CGSize(width: maxX, height: maxY)
            }
            
        }
    }
}

extension ContentScrollView {
    
    enum ScrollDirection {
        
        case vertical

        case horizontal
        
        case both
    }
}

extension ContentScrollView {
    private func realSubviewsCount() -> Int {
        let count: Int
        
        switch (showsVerticalScrollIndicator, showsHorizontalScrollIndicator) {
            
        case (true, true):
            count = 3
        case (false, false):
            count = 1
        case (true, false):
            count = 2
        case (false, true):
            count = 2
        }
        
        return count
    }
}

/**
 ▿ 12 elements
   - 0 : <UIView: 0x1034e1ea0; frame = (0 0; 375 100); tag = 100; backgroundColor = UIExtendedSRGBColorSpace 0.973935 0.811626 0.445827 1; layer = <CALayer: 0x281f7fac0>>
   - 1 : <UIView: 0x1034e2070; frame = (0 100; 375 100); tag = 101; backgroundColor = UIExtendedSRGBColorSpace 0.295578 0.385743 0.73562 1; layer = <CALayer: 0x281f7fb80>>
   - 2 : <UIView: 0x1034e2220; frame = (0 200; 375 100); tag = 102; backgroundColor = UIExtendedSRGBColorSpace 0.993539 0.781749 0.935955 1; layer = <CALayer: 0x281f7fc20>>
   - 3 : <UIView: 0x1034e23d0; frame = (0 300; 375 100); tag = 103; backgroundColor = UIExtendedSRGBColorSpace 0.644877 0.327312 0.112671 1; layer = <CALayer: 0x281f7fcc0>>
   - 4 : <UIView: 0x1034e2580; frame = (0 400; 375 100); tag = 104; backgroundColor = UIExtendedSRGBColorSpace 0.48791 0.946456 0.19134 1; layer = <CALayer: 0x281f7fd60>>
   - 5 : <UIView: 0x1034e2730; frame = (0 500; 375 100); tag = 105; backgroundColor = UIExtendedSRGBColorSpace 0.0427381 0.596567 0.117305 1; layer = <CALayer: 0x281f7fe00>>
   - 6 : <UIView: 0x1034e28e0; frame = (0 600; 375 100); tag = 106; backgroundColor = UIExtendedSRGBColorSpace 0.608721 0.774909 0.404538 1; layer = <CALayer: 0x281f7fea0>>
   - 7 : <UIView: 0x1034e2a90; frame = (0 700; 375 100); tag = 107; backgroundColor = UIExtendedSRGBColorSpace 0.786461 0.5843 0.0742772 1; layer = <CALayer: 0x281f7ff40>>
   - 8 : <UIView: 0x1034e2c40; frame = (0 800; 375 100); tag = 108; backgroundColor = UIExtendedSRGBColorSpace 0.85536 0.245545 0.696106 1; layer = <CALayer: 0x281f7ffe0>>
   - 9 : <UIView: 0x1034e2df0; frame = (0 900; 375 100); tag = 109; backgroundColor = UIExtendedSRGBColorSpace 0.779309 0.854153 0.685651 1; layer = <CALayer: 0x281f76560>>
   - 10 : <_UIScrollViewScrollIndicator: 0x1034838d0; frame = (333.667 806; 7 3); alpha = 0; autoresize = TM; layer = <CALayer: 0x281fc3fe0>>
   - 11 : <_UIScrollViewScrollIndicator: 0x103484ff0; frame = (369 770.667; 3 7); alpha = 0; autoresize = LM; layer = <CALayer: 0x281f9af00>> */
