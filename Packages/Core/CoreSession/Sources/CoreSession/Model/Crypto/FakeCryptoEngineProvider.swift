import DashTypes
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
    .mock(
      mode: validMasterKey == masterKey ? .reverseEncrypt : .failure(CryptoError.decryptionFailure))
  }

  public func sessionCryptoEngine(forEncryptedPayload payload: Data, masterKey: MasterKey) throws
    -> SessionCryptoEngine
  {
    .mock(
      mode: validMasterKey == masterKey ? .reverseEncrypt : .failure(CryptoError.decryptionFailure))
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
    -> DashTypes.CryptoEngine
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
