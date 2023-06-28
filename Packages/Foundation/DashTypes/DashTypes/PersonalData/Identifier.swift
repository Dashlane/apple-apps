import Foundation
import SwiftTreats

public struct Identifier: Codable, Hashable {
    public static func == (lhs: Identifier, rhs: Identifier) -> Bool {
        lhs.lowercasedValue == rhs.lowercasedValue
    }

        public let rawValue: String
        private let lowercasedValue: String

        public init() {
        self.init("{\(UUID().uuidString)}")
    }

    public init(_ value: String) {
        rawValue = value
        lowercasedValue = rawValue.lowercased()
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        rawValue = try container.decode(String.self)
        lowercasedValue = rawValue.lowercased()
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(lowercasedValue)
    }
}

extension Identifier: CustomStringConvertible {
    public var description: String {
        return rawValue
    }
}

extension Identifier: ExpressibleByStringLiteral {
    public init(stringLiteral value: String) {
        self.init(value)
    }
}

public extension Identifier {
    var bracketLessIdentifier: Identifier {
        guard rawValue.hasPrefix("{") && rawValue.hasSuffix("}") else {
            return self
        }
        return Identifier(rawValue.stringWithFirstAndLastCharacterRemoved())
    }
}

public extension Identifier {
    static var temporary: Self {
        return Identifier("")
    }

    var isTemporary: Bool {
        return self == .temporary
    }
}
