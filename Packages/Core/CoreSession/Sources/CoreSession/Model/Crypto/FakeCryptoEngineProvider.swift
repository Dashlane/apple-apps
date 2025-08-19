import CoreTypes
import DashlaneAPI
import Foundation

public struct FakeCryptoEngineProvider: CryptoEngineProvider {

  let validMasterKey: MasterKey
  let mode: MockCryptoEngine.OperationMode

  public init(
    validMasterKey: MasterKey = .masterPassword("valid", serverKey: nil),
    mode: MockCryptoEngine.OperationMode = .reverseEncrypt
  ) {
    self.validMasterKey = validMasterKey
    self.mode = mode
  }

  public func makeLocalKey() -> Data {
    Data([1, 2, 3, 4])
  }

  public func retrieveCryptoConfig(fromRawSettings content: Data) throws -> CryptoRawConfig? {
    return CryptoRawConfig(fixedSalt: nil, marker: "fakeConfig")
  }

  public func sessionCryptoEngine(for setting: CryptoRawConfig, masterKey: MasterKey) throws
    -> SessionCryptoEngine
  {
    .mock(mode: mode)
  }

  public func sessionCryptoEngine(forEncryptedPayload payload: Data, masterKey: MasterKey) throws
    -> SessionCryptoEngine
  {
    .mock(mode: mode)
  }

  public func defaultCryptoRawConfig(for masterKey: MasterKey) throws -> CryptoRawConfig {
    return CryptoRawConfig(fixedSalt: nil, marker: "cryptoheader")
  }

  public func cryptoEngine(for setting: CryptoRawConfig, secret: EncryptionSecret) throws
    -> CryptoEngine
  {
    return .mock(mode)
  }

  public func cryptoEngine(forKey key: Data) throws -> CryptoEngine {
    .mock(mode)
  }

  public func cryptoEngine(forEncryptedVaultKey payload: Data, recoveryKey: String) throws
    -> CoreTypes.CryptoEngine
  {
    .mock(mode)
  }

  public func retriveCryptoConfig(
    with masterKey: MasterKey, remoteKey: Data?, encryptedSettings: String,
    userDeviceAPIClient: UserDeviceAPIClient
  ) async throws -> CryptoRawConfig {
    if validMasterKey == masterKey || !masterKey.secret.isPassword {
      return CryptoRawConfig(fixedSalt: nil, marker: "fakeConfig")
    }
    throw RemoteLoginStateMachine.Error.wrongMasterKey
  }
}

extension CryptoEngineProvider where Self == FakeCryptoEngineProvider {
  static func mock(
    validMasterKey: MasterKey = .masterPassword("valid", serverKey: nil),
    mode: MockCryptoEngine.OperationMode = .reverseEncrypt
  ) -> Self {
    .init(validMasterKey: validMasterKey, mode: mode)
  }
}
