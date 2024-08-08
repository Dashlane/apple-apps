import Foundation

public struct AuthTicket: Hashable, ExpressibleByStringLiteral {

  public let value: String

  public init(value: String) {
    self.value = value
  }

  public init(stringLiteral value: StringLiteralType) {
    self.init(value: value)
  }
}
