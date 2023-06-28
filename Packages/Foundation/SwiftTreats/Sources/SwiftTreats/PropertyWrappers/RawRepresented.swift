import Foundation

@propertyWrapper
public struct RawRepresented<T: RawRepresentable> {
    private enum Storage {
        case known(T)
        case unknown(T.RawValue)
    }

    private let storage: Storage

    public var wrappedValue: T? {
        switch storage {
            case let .known(value):
                return value
            case .unknown:
                return nil
        }
    }

    public var projectedValue: T.RawValue {
        switch storage {
            case let .known(value):
                return value.rawValue
            case let .unknown(value):
                return value
        }
    }

    public init(rawValue: T.RawValue) {
        if let value = T(rawValue: rawValue) {
            storage = .known(value)
        } else {
            storage = .unknown(rawValue)
        }
    }

    public init(_ value: T) {
        storage = .known(value)
    }
}

extension RawRepresented: Codable where T.RawValue: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(T.RawValue.self)
        self.init(rawValue: value)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(projectedValue)
    }
}

extension RawRepresented: Equatable where T.RawValue: Equatable {
    public static func == (lhs: RawRepresented<T>, rhs: RawRepresented<T>) -> Bool {
        lhs.projectedValue == rhs.projectedValue
    }
}

extension RawRepresented: Hashable where T.RawValue: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(projectedValue)
    }
}
