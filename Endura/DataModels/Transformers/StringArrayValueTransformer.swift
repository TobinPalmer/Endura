import Foundation

@objc(StringArrayValueTransformer)
final class StringArrayValueTransformer: NSSecureUnarchiveFromDataTransformer {
    static let name = NSValueTransformerName(rawValue: String(describing: StringArrayValueTransformer.self))

    override static var allowedTopLevelClasses: [AnyClass] {
        [NSArray.self, NSString.self]
    }

    public static func register() {
        let transformer = StringArrayValueTransformer()
        ValueTransformer.setValueTransformer(transformer, forName: name)
    }
}
