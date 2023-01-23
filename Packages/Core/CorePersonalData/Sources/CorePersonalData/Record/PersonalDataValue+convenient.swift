import Foundation


extension PersonalDataValue: ExpressibleByStringLiteral {
    public init(stringLiteral value: StringLiteralType) {
        self = .item(value)
    }
}

extension PersonalDataValue: ExpressibleByArrayLiteral {
    public init(arrayLiteral elements: String...) {
        self = .list(elements.map { .item($0) })
    }
}

extension PersonalDataValue: ExpressibleByDictionaryLiteral {
    public init(dictionaryLiteral elements: (String, PersonalDataValue)...) {
        self = .collection(.init(uniqueKeysWithValues: elements))
    }
}

extension PersonalDataList {
    public init(_ objects: [PersonalDataObject]) {
        self = objects.map { .object($0) }
    }
}

extension PersonalDataObject {
    init(type: XMLDataType, content: PersonalDataCollection) {
        self.init(type: .init(type), content: content)
    }
}

extension PersonalDataValue {
    var item: String? {
        switch self {
            case let .item(value):
                return value
            default:
                return nil
        }
    }
    
    var collection: [String: PersonalDataValue] {
        switch self {
            case let .collection(value):
                return value
            default:
                return [:]
        }
    }
    
    var list: [PersonalDataValue] {
        switch self {
            case let .list(value):
                return value
            default:
                return []
        }
    }
    
    var object: PersonalDataObject? {
        switch self {
            case let .object(value):
                return value
            default:
                return nil
        }
    }
}
