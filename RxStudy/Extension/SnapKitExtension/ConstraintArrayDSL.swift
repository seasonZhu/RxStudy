
import SnapKit

public struct ConstraintArrayDSL {
    @discardableResult
    public func prepareConstraints(_ closure: (_ make: ConstraintMaker) -> Void) -> [Constraint] {
        var constraints = Array<Constraint>()
        for view in self.array {
            constraints.append(contentsOf: view.snp.prepareConstraints(closure))
        }
        return constraints
    }
    
    public func makeConstraints(_ closure: (_ make: ConstraintMaker) -> Void) {
        for view in self.array {
            view.snp.makeConstraints(closure)
        }
    }
    
    public func remakeConstraints(_ closure: (_ make: ConstraintMaker) -> Void) {
        for view in self.array {
            view.snp.remakeConstraints(closure)
        }
    }
    
    public func updateConstraints(_ closure: (_ make: ConstraintMaker) -> Void) {
        for view in self.array {
            view.snp.updateConstraints(closure)
        }
    }
    
    public func removeConstraints() {
        for view in self.array {
            view.snp.removeConstraints()
        }
    }
    
    /// distribute with the width that you give
    /// you should calculate the width of each item first
    ///
    /// - Parameters:
    ///   - verticalSpacing: the vertical spacing between each item
    ///   - horizontalSpacing: the horizontal spacing between each item
    ///   - tailSpacing: the spacing after the last item and the container
    ///   - maxWidth: the max width of each row or each item
    ///   - determineWidths: the width of each item, you must ensure determineWidths.count == self.array.count
    ///   - itemHeight: the height of each item
    ///   - edgeInset: the edgeInset of all item, default is UIEdgeInsets.zero
    ///                if edgeInset.left or edgeInset.right is not 0, the maxWidth will change, maxWidth -=  (edgeInset.left +  edgeInset.right)
    ///   - topConstrainView: the view before the first item
    public func distributeDetermineWidthViews(verticalSpacing: CGFloat,
                                              horizontalSpacing: CGFloat,
                                              maxWidth: CGFloat,
                                              determineWidths: [CGFloat],
                                              itemHeight: CGFloat,
                                              edgeInset: UIEdgeInsets = UIEdgeInsets.zero,
                                              topConstrainView: ConstraintView? = nil) {
        
        guard self.array.count > 1, determineWidths.count == self.array.count, let tempSuperview = commonSuperviewOfViews() else {
            return
        }
        
        var prev : ConstraintView?
        var vMinX: CGFloat = 0
        
        let maxW = maxWidth - (edgeInset.right + edgeInset.left)
        
        for (i,v) in self.array.enumerated() {
            
            let curWidth = min(determineWidths[i], maxW)
            v.snp.makeConstraints({ (make) in
                make.width.equalTo(curWidth)
                make.bottom.lessThanOrEqualTo(tempSuperview).offset(-edgeInset.bottom)
                make.height.equalTo(itemHeight)
                
                if prev == nil { // the first one
                    let tmpTarget = topConstrainView != nil ? topConstrainView!.snp.bottom : tempSuperview.snp.top
                    make.top.equalTo(tmpTarget).offset(edgeInset.top)
                    make.left.equalTo(tempSuperview).offset(edgeInset.left)
                    vMinX = curWidth + horizontalSpacing
                }
                else {
                    make.right.lessThanOrEqualToSuperview().offset(-edgeInset.right)
                    
                    if vMinX + curWidth > maxW {
                        make.top.equalTo(prev!.snp.bottom).offset(verticalSpacing)
                        make.left.equalTo(tempSuperview).offset(edgeInset.left)
                        vMinX = curWidth + horizontalSpacing
                    }
                    else {
                        make.top.equalTo(prev!)
                        make.left.equalTo(prev!.snp.right).offset(horizontalSpacing)
                        vMinX += curWidth + horizontalSpacing
                    }
                }
            })
            
            prev = v
        }
    }
    
    /// distribute with horizontal or vertical
    /// you should calculate the width of each item first
    ///
    /// - Parameters:
    ///   - axisType: which axis to distribute items along
    ///   - fixedItemSpacing: the spacing between each item, if axisType is horizontal（vertical）, fixedItemSpacing is horizontal（vertical） spacing
    ///   - fixedItemLength: if axisType is horizontal（vertical）, fixedItemLength is width（height)
    ///   - edgeInset: the edgeInset of all item, default is UIEdgeInsets.zero
    ///   - topConstrainView: the view before the first item
    public func distributeViewsAlong(axisType: NSLayoutConstraint.Axis,
                                     fixedItemSpacing: CGFloat = 0,
                                     edgeInset: UIEdgeInsets = UIEdgeInsets.zero,
                                     fixedItemLength: CGFloat? = nil,
                                     topConstrainView: ConstraintView? = nil) {
        
        guard self.array.count > 1, let tempSuperview = commonSuperviewOfViews() else {
            return
        }
        
        if axisType == .vertical {
            self.array.first?.snp.makeConstraints({ (make) in
                if fixedItemLength != nil {
                    make.height.equalTo(fixedItemLength!)
                }
                
                let tmpTarget = topConstrainView != nil ? topConstrainView!.snp.bottom : tempSuperview.snp.top
                make.top.equalTo(tmpTarget).offset(edgeInset.top)
                make.centerX.equalTo(tempSuperview)
                make.left.equalTo(tempSuperview).offset(edgeInset.left).priority(.high)
                make.right.equalTo(tempSuperview).offset(-edgeInset.right).priority(.high)
                make.bottom.lessThanOrEqualTo(tempSuperview).offset(-edgeInset.bottom)
            })
            
            for (preView, curView) in zip(self.array, self.array.dropFirst()) {
                curView.snp.makeConstraints({ (make) in
                    if fixedItemLength != nil {
                        make.height.equalTo(fixedItemLength!)
                    }
                    make.top.equalTo(preView.snp.bottom).offset(fixedItemSpacing)
                    make.centerX.equalTo(tempSuperview)
                    make.left.right.equalTo(preView).priority(.high)
                    make.bottom.lessThanOrEqualTo(tempSuperview).offset(-edgeInset.bottom)
                })
            }
        }
        else {
            self.array.first?.snp.makeConstraints({ (make) in
                if fixedItemLength != nil {
                    make.width.equalTo(fixedItemLength!)
                }
                
                let tmpTarget = topConstrainView != nil ? topConstrainView!.snp.bottom : tempSuperview.snp.top
                make.top.equalTo(tmpTarget).offset(edgeInset.top)
                make.left.equalTo(tempSuperview).offset(edgeInset.left)
                make.right.lessThanOrEqualTo(tempSuperview).offset(-edgeInset.right)
                make.bottom.lessThanOrEqualTo(tempSuperview).offset(-edgeInset.bottom)
            })
            
            for (preView, curView) in zip(self.array, self.array.dropFirst()) {
                curView.snp.makeConstraints({ (make) in
                    if fixedItemLength != nil {
                        make.width.equalTo(fixedItemLength!)
                    }
                    
                    make.top.equalTo(preView)
                    make.left.equalTo(preView.snp.right).offset(fixedItemSpacing)
                    make.right.lessThanOrEqualTo(tempSuperview).offset(-edgeInset.right)
                    make.bottom.lessThanOrEqualTo(tempSuperview).offset(-edgeInset.bottom)
                })
            }
        }
    }
    
    
    /// distribute with the width that you give
    /// you should calculate the width of each item first
    ///
    /// - Parameters:
    ///   - verticalSpacing: the vertical spacing between each item
    ///   - horizontalSpacing: the horizontal spacing between each item
    ///   - itemHeight: the height of each item
    ///   - edgeInset: the edgeInset of all item, default is UIEdgeInsets.zero
    ///   - topConstrainView: the view before the first item
    public func distributeSudokuViews(verticalSpacing: CGFloat,
                                      horizontalSpacing: CGFloat,
                                      warpCount: Int,
                                      edgeInset: UIEdgeInsets = UIEdgeInsets.zero,
                                      itemHeight: CGFloat? = nil,
                                      topConstrainView: ConstraintView? = nil) {
        
        guard self.array.count > 1, warpCount >= 1, let tempSuperview = commonSuperviewOfViews() else {
            return
        }
        
        let columnCount = warpCount
        let rowCount = self.array.count % warpCount == 0 ? self.array.count / warpCount : self.array.count / warpCount + 1;
        
        var prev : ConstraintView?
        
        for (i,v) in self.array.enumerated() {
            
            let currentRow = i / warpCount
            let currentColumn = i % warpCount
            
            v.snp.makeConstraints({ (make) in
                if prev != nil {
                    make.width.height.equalTo(prev!)
                }
                if currentRow == 0 {//fisrt row
                    let tmpTarget = topConstrainView != nil ? topConstrainView!.snp.bottom : tempSuperview.snp.top
                    make.top.equalTo(tmpTarget).offset(edgeInset.top)
                    if itemHeight != nil {
                        make.height.equalTo(itemHeight!)
                    }
                }
                if currentRow == rowCount - 1 {//last row
                    if currentRow != 0 && i - columnCount >= 0 {
                        make.top.equalTo(self.array[i-columnCount].snp.bottom).offset(verticalSpacing)
                    }
                    
                    if itemHeight != nil {
                        make.bottom.lessThanOrEqualTo(tempSuperview).offset(-edgeInset.bottom)
                    }
                    else {
                        make.bottom.equalTo(tempSuperview).offset(-edgeInset.bottom)
                    }
                }
                
                if currentRow != 0 && currentRow != rowCount - 1 {//other row
                    make.top.equalTo(self.array[i-columnCount].snp.bottom).offset(verticalSpacing);
                }
                
                if currentColumn == 0 {//first col
                    make.left.equalTo(tempSuperview).offset(edgeInset.left)
                }
                if currentColumn == warpCount - 1 {//last col
                    if currentColumn != 0 {
                        make.left.equalTo(prev!.snp.right).offset(horizontalSpacing)
                    }
                    make.right.equalTo(tempSuperview).offset(-edgeInset.right)
                }
                
                if currentColumn != 0 && currentColumn != warpCount - 1 {//other col
                    make.left.equalTo(prev!.snp.right).offset(horizontalSpacing);
                }
            })
            prev = v
        }
    }
    
    
    public var target: AnyObject? {
        return self.array as AnyObject
    }
    
    internal let array: Array<ConstraintView>
    
    internal init(array: Array<ConstraintView>) {
        self.array = array
    }
}

private extension ConstraintArrayDSL {
    func commonSuperviewOfViews() -> ConstraintView? {
        var commonSuperview : ConstraintView?
        var previousView : ConstraintView?
        
        for view in self.array {
            if previousView != nil {
                commonSuperview = view.closestCommonSuperview(commonSuperview)
            }else {
                commonSuperview = view
            }
            previousView = view
        }
        return commonSuperview
    }
}

private extension ConstraintView {
    func closestCommonSuperview(_ view : ConstraintView?) -> ConstraintView? {
        var closestCommonSuperview: ConstraintView?
        var secondViewSuperview: ConstraintView? = view
        while closestCommonSuperview == nil && secondViewSuperview != nil {
            var firstViewSuperview: ConstraintView? = self
            while closestCommonSuperview == nil && firstViewSuperview != nil {
                if secondViewSuperview == firstViewSuperview {
                    closestCommonSuperview = secondViewSuperview
                }
                firstViewSuperview = firstViewSuperview?.superview
            }
            secondViewSuperview = secondViewSuperview?.superview
        }
        return closestCommonSuperview
    }
}
