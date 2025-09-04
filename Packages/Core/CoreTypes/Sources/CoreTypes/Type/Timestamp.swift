import Foundation

public struct Timestamp: Hashable {
  public var rawValue: UInt64

  public init(_ rawValue: UInt64) {
    self.rawValue = rawValue
  }

  public init(_ rawValue: Int) {
    self.rawValue = UInt64(rawValue)
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

extension Timestamp {
  public static var now: Timestamp {
    return Timestamp(date: Date())
  }

  public static var distantPast: Timestamp {
    return Timestamp(0)
  }

  public static var distantFuture: Timestamp {
    return Timestamp(UInt64.max)
  }
}

extension Timestamp {
  public init(timeInterval: TimeInterval) {
    self.init(timeInterval.milliseconds)
  }

  public init(date: Date) {
    self.init(timeInterval: date.timeIntervalSince1970)
  }

  public var date: Date {
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

extension TimestampByIds {
  public init(_ raw: TimestampByRawIds) {
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

extension Timestamp {
  public var millisecondsSince1970: UInt64 {
    self.rawValue
  }
}

extension TimeInterval {
  fileprivate var milliseconds: UInt64 {
    UInt64((self * 1000.0).rounded())
  }
}
