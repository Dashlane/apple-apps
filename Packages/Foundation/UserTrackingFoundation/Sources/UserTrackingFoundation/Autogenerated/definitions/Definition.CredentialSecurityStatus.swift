import Foundation

extension Definition {

  public struct `CredentialSecurityStatus`: Encodable, Sendable {
    public init(
      `isCompromised`: Bool? = nil, `isDeleted`: Bool? = nil, `isExcluded`: Bool? = nil,
      `isReused`: Bool? = nil,
      `isWeak`: Bool? = nil
    ) {
      self.isCompromised = isCompromised
      self.isDeleted = isDeleted
      self.isExcluded = isExcluded
      self.isReused = isReused
      self.isWeak = isWeak
    }
    public let isCompromised: Bool?
    public let isDeleted: Bool?
    public let isExcluded: Bool?
    public let isReused: Bool?
    public let isWeak: Bool?
  }
}
