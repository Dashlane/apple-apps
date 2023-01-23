import Foundation
import DashTypes

@propertyWrapper
public struct Linked<T: PersonalDataCodable & Equatable>: Codable, Equatable {
    public var identifier: Identifier?
    public var wrappedValue: T? {
        didSet {
            identifier = wrappedValue?.id
        }
    }
    
    public init(_ wrappedValue: T? = nil) {
        self.wrappedValue = wrappedValue
        identifier = wrappedValue?.id
    }
    
        public init(identifier: Identifier?) {
        self.identifier = identifier
    }
    
    public var projectedValue: Identifier? {
        identifier
    }
}

extension Linked {
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        if let value = identifier?.rawValue {
            try container.encode(value)
        } else {
            try container.encodeNil()
        }
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        identifier = try Identifier(container.decode(String.self))
    }
}
