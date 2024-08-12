import Foundation

public struct Empty: Codable, Equatable, Hashable, Sendable {
  public init() {}
}

extension Empty? {
  init() {
    self = .none
  }
}
