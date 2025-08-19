import Foundation

public struct PasskeysPasskeyBody: Codable, Hashable, Sendable {
  public enum CodingKeys: String, CodingKey {
    case passkeyId = "passkeyId"
    case encryptionKey = "encryptionKey"
  }

  public let passkeyId: String
  public let encryptionKey: PasskeysPasskeyEncryptionKey

  public init(passkeyId: String, encryptionKey: PasskeysPasskeyEncryptionKey) {
    self.passkeyId = passkeyId
    self.encryptionKey = encryptionKey
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(passkeyId, forKey: .passkeyId)
    try container.encode(encryptionKey, forKey: .encryptionKey)
  }
}
