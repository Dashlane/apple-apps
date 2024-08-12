import CorePasswords
import CorePersonalData
import CoreSession
import CoreUserTracking
import DashTypes
import DashlaneAPI
import Foundation
import LoginKit
import VaultKit

struct AccountRecoveryKeySetupService {
  let login: Login
  let userAPIClient: UserDeviceAPIClient
  let syncService: SyncServiceProtocol
  let syncedSettingsService: SyncedSettingsService
  let masterKey: MasterKey
  let logger: Logger
  let appAPIClient: AppAPIClient
  let cryptoConfig: CryptoRawConfig
  let activityReporter: ActivityReporterProtocol
  let cryptoEngineProvider: CoreSession.CryptoEngineProvider

  enum Error: Swift.Error {
    case couldNotConvertMasterKey
    case couldNotConvertToString
  }

  init(
    login: Login,
    cryptoConfig: CryptoRawConfig,
    cryptoEngineProvider: CoreSession.CryptoEngineProvider,
    appAPIClient: AppAPIClient,
    userAPIClient: UserDeviceAPIClient,
    syncService: SyncServiceProtocol,
    syncedSettingsService: SyncedSettingsService,
    masterKey: MasterKey,
    logger: Logger,
    activityReporter: ActivityReporterProtocol
  ) {
    self.login = login
    self.userAPIClient = userAPIClient
    self.syncService = syncService
    self.syncedSettingsService = syncedSettingsService
    self.masterKey = masterKey
    self.logger = logger
    self.appAPIClient = appAPIClient
    self.cryptoConfig = cryptoConfig
    self.activityReporter = activityReporter
    self.cryptoEngineProvider = cryptoEngineProvider
  }

  func fetchKeyStatus() async throws -> Bool {
    return try await appAPIClient.accountrecovery.getStatus(login: login.email).enabled
  }

  func generateAccountRecoveryKey() -> String {
    return PasswordGenerator(length: 28, composition: [.upperCaseLetters, .numerals]).generate()
  }

  func activateAccountRecoveryKey(_ accountRecoveryKey: String) async throws {

    let encryptedSessionKey = try encryptMasterKey(with: accountRecoveryKey)

    let activationResponse = try await userAPIClient.accountrecovery.requestActivation(
      encryptedVaultKey: encryptedSessionKey)
    syncedSettingsService[\.accountRecoveryKeyInfo] = AccountRecoveryKeyInfo(
      recoveryKey: accountRecoveryKey, recoveryId: activationResponse.recoveryId)
    do {
      try await syncService.syncAndDisable()
      try await userAPIClient.accountrecovery.confirmActivation(
        recoveryId: activationResponse.recoveryId)
    } catch {
      syncedSettingsService[\.accountRecoveryKeyInfo] = nil
      throw error
    }
    syncService.enableSync(triggeredBy: .manual)
  }

  func encryptMasterKey(with accountRecoveryKey: AccountRecoveryKey) throws -> Base64EncodedString {
    let config = CryptoRawConfig(fixedSalt: nil, marker: cryptoConfig.marker)
    let cryptoEngine = try cryptoEngineProvider.cryptoEngine(
      for: config, secret: .password(accountRecoveryKey))

    guard let valueToEncrypt = masterKey.valueToEncrypt else {
      throw Error.couldNotConvertMasterKey
    }
    let encryptedData = try cryptoEngine.encrypt(valueToEncrypt)

    return encryptedData.base64EncodedString()
  }

  func deactivateAccountRecoveryKey(
    for reason: UserDeviceAPIClient.Accountrecovery.Deactivate.Body.Reason
  ) async throws {
    try await userAPIClient.accountrecovery.deactivate(reason: reason)
    syncedSettingsService[\.accountRecoveryKeyInfo] = nil
    if let reason = reason.logReason {
      activityReporter.report(UserEvent.DeleteAccountRecoveryKey(deleteKeyReason: reason))
    }
    Task {
      do {
        try await syncService.syncAndDisable()
      } catch {
        logger.info("Account Recovery Key deactivated but settings not synced")
      }
      syncService.enableSync(triggeredBy: .manual)
    }
  }
}

extension AccountRecoveryKeySetupService {
  static var mock: AccountRecoveryKeySetupService {
    AccountRecoveryKeySetupService(
      login: Login("_"),
      cryptoConfig: CryptoRawConfig(
        fixedSalt: nil, marker: "$1$argon2d$16$3$32768$2$aes256$cbchmac$16$"),
      cryptoEngineProvider: FakeCryptoEngineProvider(),
      appAPIClient: .fake,
      userAPIClient: .fake,
      syncService: .mock(),
      syncedSettingsService: .mock,
      masterKey: .masterPassword("_"),
      logger: LoggerMock(),
      activityReporter: .mock)
  }
}

extension MasterKey {
  var valueToEncrypt: Data? {
    switch self {
    case let .masterPassword(password, _):
      return password.data(using: .utf8)
    case let .ssoKey(ssoKey):
      return ssoKey
    }
  }
}

extension UserDeviceAPIClient.Accountrecovery.Deactivate.Body.Reason {
  var logReason: Definition.DeleteKeyReason? {
    switch self {
    case .keyUsed:
      return .recoveryKeyUsed
    case .settings:
      return .settingDisabled
    case .vaultKeyChange:
      return .vaultKeyChanged
    case .undecodable:
      return nil
    }
  }
}
