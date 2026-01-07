import SnapKit

extension String {
    func size(withFont font: UIFont) -> CGSize {
        let attributes = [NSAttributedString.Key.font: font]
        return (self as NSString).size(withAttributes: attributes)
    }
}

@MainActor
extension Array where Element: ConstraintView {
    
    public var snp: ConstraintArrayDSL {
        return ConstraintArrayDSL(array: self)
    }
}
