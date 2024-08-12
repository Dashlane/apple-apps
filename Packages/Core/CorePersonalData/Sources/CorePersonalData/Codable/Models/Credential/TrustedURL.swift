import Foundation

public struct TrustedURL: Codable, Hashable, Equatable {

  public enum CodingKeys: String, CodingKey {
    case url = "trustedUrl"
    case creationDate = "trustedUrlExpire"
  }

  public let url: String
  public let creationDate: Date?

  public init(url: String, creationDate: Date?) {
    self.url = url
    self.creationDate = creationDate
  }

  static public func == (lhs: TrustedURL, rhs: TrustedURL) -> Bool {
    return lhs.url == rhs.url
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(url)
  }
}
