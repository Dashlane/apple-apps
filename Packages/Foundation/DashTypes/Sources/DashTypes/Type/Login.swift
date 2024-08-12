import Foundation

public struct Login: Hashable, Codable, Sendable {
  public let email: String

  public init(_ email: String) {
    self.email = email.lowercased().trimmingCharacters(in: CharacterSet.whitespaces)
  }
}

extension Login: ExpressibleByStringLiteral {
  public init(stringLiteral value: String) {
    self.init(value)
  }
}
