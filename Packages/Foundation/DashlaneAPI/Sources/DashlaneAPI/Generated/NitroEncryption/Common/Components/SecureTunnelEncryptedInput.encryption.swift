import Foundation

public struct SecureTunnelEncryptedInput: Codable, Hashable, Sendable {
  public enum CodingKeys: String, CodingKey {
    case tunnelUuid = "tunnelUuid"
    case encryptedData = "encryptedData"
  }

  public let tunnelUuid: String
  public let encryptedData: String

  public init(tunnelUuid: String, encryptedData: String) {
    self.tunnelUuid = tunnelUuid
    self.encryptedData = encryptedData
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(tunnelUuid, forKey: .tunnelUuid)
    try container.encode(encryptedData, forKey: .encryptedData)
  }
}
