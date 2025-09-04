import Foundation

public struct SecurefileSecureFileResponse: Codable, Hashable, Sendable {
  public enum CodingKeys: String, CodingKey {
    case quota = "quota"
  }

  public let quota: SecurefileQuota

  public init(quota: SecurefileQuota) {
    self.quota = quota
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(quota, forKey: .quota)
  }
}
