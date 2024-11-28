import CoreCrypto
import CorePersonalData
import CoreSession
import DashTypes
import DashlaneAPI
import Foundation

public struct SessionCryptoEngineProvider: CoreSession.CryptoEngineProvider {

  let logger: Logger

  public init(logger: Logger) {
    self.logger = logger
  }

  public func makeLocalKey() -> Data {
    Data.random(ofSize: 64)
  }

  public func retrieveCryptoConfig(fromRawSettings content: Data) throws -> CryptoRawConfig? {
    return try Settings.makeSettings(compressedContent: content).cryptoConfig
  }

  public func sessionCryptoEngine(for config: CryptoRawConfig, masterKey: CoreSession.MasterKey)
    throws -> SessionCryptoEngine
  {
    return try ConfigurableCryptoEngineImpl(secret: masterKey.secret, config: config)
  }

  public func sessionCryptoEngine(
    forEncryptedPayload payload: Data, masterKey: CoreSession.MasterKey
  ) throws -> SessionCryptoEngine {
    return try ConfigurableCryptoEngineImpl(secret: masterKey.secret, encryptedData: payload)
  }

  public func defaultCryptoRawConfig(for masterKey: CoreSession.MasterKey) throws -> CryptoRawConfig
  {
    switch masterKey {
    case .masterPassword:
      return CryptoRawConfig.masterPasswordBasedDefault
    case .ssoKey:
      return CryptoRawConfig.noDerivationDefault
    }
  }

  public func cryptoEngine(forKey key: Data) throws -> CryptoEngine {
    let config: CryptoConfiguration = key.count == 64 ? .defaultNoDerivation : .legacyNoDerivation
    return
      try config
      .makeCryptoEngine(secret: .key(key), fixedSalt: nil)
  }

  public func cryptoEngine(for config: CryptoRawConfig, secret: EncryptionSecret) throws
    -> CryptoEngine
  {
    try CryptoConfiguration(rawConfigMarker: config.marker)
      .makeCryptoEngine(secret: secret, fixedSalt: config.fixedSalt)
  }

  public func cryptoEngine(forEncryptedVaultKey payload: Data, recoveryKey: AccountRecoveryKey)
    throws -> CryptoEngine
  {
    return try CryptoConfiguration(encryptedData: payload)
      .makeCryptoEngine(secret: .password(recoveryKey))
  }

  public func retriveCryptoConfig(
    with masterKey: CoreSession.MasterKey,
    remoteKey: Data?,
    encryptedSettings: String,
    userDeviceAPIClient: UserDeviceAPIClient
  ) async throws -> CryptoRawConfig {
    guard let encryptedSettings = Data(base64Encoded: encryptedSettings) else {
      throw RemoteLoginStateMachine.Error.invalidSettings
    }

    let sessionCryptoEngine = try sessionCryptoEngine(
      forEncryptedPayload: encryptedSettings,
      masterKey: masterKey)
    let decryptSettingEngine =
      if let remoteKey {
        try cryptoEngine(forKey: remoteKey)
      } else {
        sessionCryptoEngine
      }

    guard let rawSettings = try? decryptSettingEngine.decrypt(encryptedSettings) else {
      throw RemoteLoginStateMachine.Error.wrongMasterKey
    }

    var cryptoConfig =
      if masterKey.secret.isPassword,
        let configFromSettings = try? retrieveCryptoConfig(fromRawSettings: rawSettings)
      {
        configFromSettings
      } else {
        sessionCryptoEngine.config
      }

    if masterKey.secret.isPassword,
      let status = try await userDeviceAPIClient.premium.getPremiumStatus().b2bStatus,
      status.statusCode == .inTeam,
      let teamSpaceHeader = status.currentTeam?.teamInfo.cryptoForcedPayload
    {
      cryptoConfig = CryptoRawConfig(
        fixedSalt: cryptoConfig.fixedSalt,
        userMarker: cryptoConfig.marker,
        teamSpaceMarker: teamSpaceHeader)
    }

    return cryptoConfig
  }

}
