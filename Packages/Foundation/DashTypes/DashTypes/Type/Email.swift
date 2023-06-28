import Foundation

public struct Email: ExpressibleByStringLiteral, CustomStringConvertible, Equatable {
        static let regex = try! NSRegularExpression(pattern: "[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:\\" +
                                                "_" +
                                                "(?:[a-z0-9-]*[a-z0-9])?\\.)+[a-z0-9]" +
                                                "(?:[a-z0-9-]*[a-z0-9])?", options: .caseInsensitive)
            public let address: String

            public let displayName: String?

    public var description: String {
        if let displayName {
            return "\(displayName)<\(address)>"
        } else {
            return address
        }
    }

        public var isValid: Bool {
        let expectedRange = NSRange(location: 0, length: address.count)
        return Self.regex.numberOfMatches(in: address, range: expectedRange) == 1
    }

    public init(_ stringValue: String) {
        let addressStartIndex = stringValue.firstIndex(of: "<" as Character)
        let addressEndIndex = stringValue.firstIndex(of: ">" as Character)
        let address: String

        if let start = addressStartIndex, let end = addressEndIndex, start < end {
            address = String(stringValue[stringValue.index(after: start)..<end])
            if start > stringValue.startIndex {
                displayName = String(stringValue[...stringValue.index(before: start)]).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            } else {
                displayName = nil
            }
        } else {
            address = stringValue
            displayName = nil
        }

        self.address = address.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }

    public init(stringLiteral: String) {
        self.init(stringLiteral)
    }
}
