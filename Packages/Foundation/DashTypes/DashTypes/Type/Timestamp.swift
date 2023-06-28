import Foundation

public struct Timestamp: Hashable {
    public var rawValue: UInt64

    public init(_ rawValue: UInt64) {
        self.rawValue = rawValue
    }

    public init?(string: String) {
        guard let rawValue = UInt64(string) else {
            return nil
        }
        self.init(rawValue)
    }
}

extension Timestamp: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        rawValue = try container.decode(UInt64.self)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

extension Timestamp: Comparable {
    public static func < (lhs: Timestamp, rhs: Timestamp) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

public extension Timestamp {
    static var now: Timestamp {
        return Timestamp(date: Date())
    }

    static var distantPast: Timestamp {
        return Timestamp(0)
    }

    static var distantFuture: Timestamp {
        return Timestamp(UInt64.max)
    }
}

public extension Timestamp {
    init(timeInterval: TimeInterval) {
        self.init(timeInterval.milliseconds)
    }

    init(date: Date) {
        self.init(timeInterval: date.timeIntervalSince1970)
    }

    var date: Date {
        return Date(timeIntervalSince1970: TimeInterval(rawValue) / 1000)
    }
}

extension Timestamp: CustomDebugStringConvertible {
    public var debugDescription: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .short

        return "Timestamp(\(rawValue):\(formatter.string(for: date) ?? ""))"
    }
}

extension Timestamp: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: UInt64) {
        rawValue = value
    }
}

public typealias TimestampByRawIds = [String: Timestamp]
public typealias TimestampByIds = [Identifier: Timestamp]

public extension TimestampByIds {
    init( _ raw: TimestampByRawIds) {
        var timestampByIds: [Identifier: Timestamp] = [:]
        raw
            .sorted { $0.value < $1.value } 
            .forEach {
                timestampByIds[Identifier($0.key)] = $0.value
            }

        self = timestampByIds
    }
}

public struct TimestampIdPair: Equatable, Hashable {
    public let id: Identifier
    public let timestamp: Timestamp

    public init(id: Identifier, timestamp: Timestamp) {
        self.id = id
        self.timestamp = timestamp
    }
}

public extension Timestamp {
    var millisecondsSince1970: UInt64 {
        self.date.timeIntervalSince1970.milliseconds
    }
}

private extension TimeInterval {
    var milliseconds: UInt64 {
        UInt64((self * 1000.0).rounded())
    }
}
