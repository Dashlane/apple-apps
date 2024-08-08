import DashTypes
import DashlaneAPI
import Foundation
import SwiftTreats

public protocol CryptoEngineProvider: Sendable {
  func retrieveCryptoConfig(fromRawSettings content: Data) throws -> CryptoRawConfig?

  func makeLocalKey() -> Data

  func sessionCryptoEngine(for setting: CryptoRawConfig, masterKey: MasterKey) throws
    -> SessionCryptoEngine
  func sessionCryptoEngine(forEncryptedPayload payload: Data, masterKey: MasterKey) throws
    -> SessionCryptoEngine
  func defaultCryptoRawConfig(for masterKey: MasterKey) throws -> CryptoRawConfig

  func cryptoEngine(forKey key: Data) throws -> CryptoEngine

  func cryptoEngine(for setting: CryptoRawConfig, secret: EncryptionSecret) throws -> CryptoEngine
  func cryptoEngine(forEncryptedVaultKey payload: Data, recoveryKey: AccountRecoveryKey) throws
    -> CryptoEngine

  func retriveCryptoConfig(
    with masterKey: MasterKey,
    remoteKey: Data?,
    encryptedSettings: String,
    userDeviceAPIClient: UserDeviceAPIClient
  ) async throws -> CryptoRawConfig
}

extension CryptoEngineProvider {
  public func sessionCryptoEngine(for masterKey: MasterKey) throws -> SessionCryptoEngine {
    try self.sessionCryptoEngine(for: defaultCryptoRawConfig(for: masterKey), masterKey: masterKey)
  }
}

public typealias SessionCryptoEngine = ConfigurableCryptoEngine
public typealias AccountRecoveryKey = String

extension CryptoEngineProvider {
  public func decipherRemoteKey(
    ssoKey: String,
    remoteKey: EncryptedRemoteKey?,
    authTicket: AuthTicket
  ) throws -> SSOKeys {
    guard let ssoKey = Data(base64Encoded: ssoKey),
      let remoteKey = remoteKey
    else {
      throw SSOAccountError.userDataNotFetched
    }

    guard let remoteKeyData = Data(base64Encoded: remoteKey.key),
      let cryptoEngine = try? cryptoEngine(forKey: ssoKey),
      let decipheredRemoteKey = try? cryptoEngine.decrypt(remoteKeyData)
    else {
      throw SSOAccountError.invalidServiceProviderKey
    }
    return SSOKeys(remoteKey: decipheredRemoteKey, ssoKey: ssoKey, authTicket: authTicket)
  }
}
