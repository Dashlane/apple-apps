import CoreSession
import CoreSync
import CoreTypes
import Foundation
import LoginKit
import SwiftTreats
import UserTrackingFoundation

struct AccountMigrationConfiguration: Hashable, Sendable {
  let session: Session
  let mode: MigrationUploadMode
  let masterKey: CoreSession.MasterKey
  let remoteKey: Data?
  let cryptoConfig: CryptoRawConfig
  let authTicket: CoreSync.AuthTicket?
  let loginOTPOption: ThirdPartyOTPOption?
  let reportedType: Definition.CryptoMigrationType

  private init(
    session: Session,
    mode: MigrationUploadMode,
    masterKey: CoreSession.MasterKey,
    remoteKey: Data?,
    cryptoConfig: CryptoRawConfig,
    authTicket: CoreSync.AuthTicket?,
    loginOTPOption: ThirdPartyOTPOption?,
    reportedType: Definition.CryptoMigrationType
  ) {
    self.session = session
    self.mode = mode
    self.masterKey = masterKey
    self.remoteKey = remoteKey
    self.cryptoConfig = cryptoConfig
    self.authTicket = authTicket
    self.loginOTPOption = loginOTPOption
    self.reportedType = reportedType
  }

  static func masterPasswordToMasterPassword(
    session: Session,
    masterPassword: String
  ) -> Self {
    let currentMasterKey = session.authenticationMethod.sessionKey

    return AccountMigrationConfiguration(
      session: session,
      mode: .masterKeyChange,
      masterKey: .masterPassword(masterPassword, serverKey: currentMasterKey.serverKey),
      remoteKey: nil,
      cryptoConfig: .masterPasswordBasedDefault,
      authTicket: nil,
      loginOTPOption: session.configuration.info.loginOTPOption,
      reportedType: .masterPasswordChange
    )
  }

  static func masterPasswordToSSO(
    session: Session,
    authTicket: CoreSession.AuthTicket,
    serviceProviderKey: String,
    sessionCryptoEngineProvider: SessionCryptoEngineProvider
  ) throws -> Self {
    let ssoServerKey = Data.random(ofSize: 64)
    let remoteKey = Data.random(ofSize: 64)
    guard let serviceProviderKeyData = Data(base64Encoded: serviceProviderKey) else {
      throw AccountError.unknown
    }

    let ssoKey = ssoServerKey ^ serviceProviderKeyData
    let config = try sessionCryptoEngineProvider.defaultCryptoRawConfig(for: .ssoKey(ssoKey))
    let verification = Verification(type: .sso, ssoServerKey: ssoServerKey.base64EncodedString())

    return AccountMigrationConfiguration(
      session: session,
      mode: .masterKeyChange,
      masterKey: .ssoKey(ssoKey),
      remoteKey: remoteKey,
      cryptoConfig: config,
      authTicket: AuthTicket(token: authTicket.value, verification: verification),
      loginOTPOption: nil,
      reportedType: .masterPasswordToSso
    )
  }

  static func ssoToMasterPassword(
    session: Session,
    authTicket: CoreSession.AuthTicket,
    newMasterPassword: String,
    cryptoConfigHeader: CryptoEngineConfigHeader?
  ) -> Self {
    let masterPasswordBasedConfig = CryptoRawConfig.masterPasswordBasedDefault

    let cryptoConfig = CryptoRawConfig(
      fixedSalt: masterPasswordBasedConfig.fixedSalt,
      userMarker: masterPasswordBasedConfig.marker,
      teamSpaceMarker: cryptoConfigHeader
    )

    let serverKey = session.authenticationMethod.sessionKey.serverKey

    return AccountMigrationConfiguration(
      session: session,
      mode: .masterKeyChange,
      masterKey: .masterPassword(newMasterPassword, serverKey: serverKey),
      remoteKey: nil,
      cryptoConfig: cryptoConfig,
      authTicket: AuthTicket(
        token: authTicket.value, verification: Verification(type: .emailToken)),
      loginOTPOption: nil,
      reportedType: .ssoToMasterPassword
    )
  }
}

extension AccountMigrationConfiguration {
  static var mock: Self {
    .masterPasswordToMasterPassword(session: .mock, masterPassword: "password")
  }
}
