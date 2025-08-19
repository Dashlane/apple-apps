import Foundation

public struct SecureTunnelEncryptedOutput: Codable, Hashable, Sendable {
  public enum CodingKeys: String, CodingKey {
    case encryptedData = "encryptedData"
  }

  public let encryptedData: String

  public init(encryptedData: String) {
    self.encryptedData = encryptedData
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(encryptedData, forKey: .encryptedData)
  }
}
