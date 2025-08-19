import Foundation
import LogFoundation
import SwiftTreats

public struct Identifier: Codable, Hashable, Sendable {
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

extension Identifier {
  public var bracketLessIdentifier: Identifier {
    guard rawValue.hasPrefix("{") && rawValue.hasSuffix("}") else {
      return self
    }
    return Identifier(rawValue.stringWithFirstAndLastCharacterRemoved())
  }
}

extension Identifier {
  public static var temporary: Self {
    return Identifier("")
  }

  public var isTemporary: Bool {
    return self == .temporary
  }
}

extension Identifier: Loggable {
  public func log() -> LogMessage {
    "\(rawValue, privacy: .public)"
  }
}
