import Foundation

public enum DeviceTransferOrigin {
  case sender
  case receiver
}

public protocol DeviceTransferCryptoKeysProvider: Sendable {

  var publicKeyString: Base64EncodedString { get }
  func publicKeyHash() throws -> Base64EncodedString
  func securityChallengeKeys(
    using publicKey: Base64EncodedString, login: String, transferId: String,
    origin: DeviceTransferOrigin
  ) throws -> SecurityChallengeKeys
  func compare(_ key: Base64EncodedString, hashedKey: Base64EncodedString) throws -> Bool
}

extension DeviceTransferCryptoKeysProvider where Self == DeviceTransferCryptoKeysProviderMock {
  public static func mock(keys: DeviceTransferCryptoKeysProviderMock.Keys = .mock)
    -> DeviceTransferCryptoKeysProvider
  {
    DeviceTransferCryptoKeysProviderMock(keys: keys)
  }
}
