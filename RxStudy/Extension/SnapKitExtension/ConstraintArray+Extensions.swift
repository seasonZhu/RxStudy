import SnapKit

extension String {
    func size(withFont font: UIFont) -> CGSize {
        let attributes = [NSAttributedString.Key.font: font]
        return (self as NSString).size(withAttributes: attributes)
    }
}

extension Array where Element: ConstraintView {
    
    @MainActor public var snp: ConstraintArrayDSL {
        return ConstraintArrayDSL(array: self)
    }
}
