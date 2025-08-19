import Foundation

public struct SecurityChallengeKeys: Hashable, Sendable {
  public let transferId: String
  public let symmetricKey: Bytes
  public let passphrase: [String]

  public init(
    transferId: String,
    symmetricKey: [UInt8],
    passphrase: [String]
  ) {
    self.transferId = transferId
    self.symmetricKey = symmetricKey
    self.passphrase = passphrase
  }
}
