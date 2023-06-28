import Foundation
import CoreSession
import DashlaneAPI
import CorePersonalData
import LoginKit
import DashlaneCrypto
import DashTypes
import CorePasswords
import CoreUserTracking

typealias AccountRecoveryKey = String

struct AccountRecoveryKeyService {
    let login: Login
    let userAPIClient: UserDeviceAPIClient
    let syncService: SyncServiceProtocol
    let syncedSettingsService: SyncedSettingsService
    let masterKey: MasterKey
    let logger: Logger
    let appAPIClient: AppAPIClient
    let cryptoConfig: CryptoRawConfig
    let activityReporter: ActivityReporterProtocol

    enum Error: Swift.Error {
        case couldNotEncrypt
        case couldNotConvertToString
    }

    init(login: Login,
         cryptoConfig: CryptoRawConfig,
         appAPIClient: AppAPIClient,
         userAPIClient: UserDeviceAPIClient,
         syncService: SyncServiceProtocol,
         syncedSettingsService: SyncedSettingsService,
         masterKey: MasterKey,
         logger: Logger,
         activityReporter: ActivityReporterProtocol) {
        self.login = login
        self.userAPIClient = userAPIClient
        self.syncService = syncService
        self.syncedSettingsService = syncedSettingsService
        self.masterKey = masterKey
        self.logger = logger
        self.appAPIClient = appAPIClient
        self.cryptoConfig = cryptoConfig
        self.activityReporter = activityReporter
    }

    func fetchKeyStatus() async throws -> Bool {
        return try await appAPIClient.accountrecovery.getStatus(login: login.email).enabled
    }

    func generateAccountRecoveryKey() -> String {
        return PasswordGenerator(length: 28, composition: [.upperCaseLetters, .numerals]).generate()
    }

    func activateAccountRecoveryKey(_ accountRecoveryKey: String) async throws {

        let encryptedSessionKey = try encryptMasterKey(with: accountRecoveryKey)

        let activationResponse = try await userAPIClient.accountrecovery.requestActivation(encryptedVaultKey: encryptedSessionKey)
        syncedSettingsService[\.accountRecoveryKeyInfo] = AccountRecoveryKeyInfo(recoveryKey: accountRecoveryKey, recoveryId: activationResponse.recoveryId)
        do {
            try await syncService.syncAndDisable()
            try await userAPIClient.accountrecovery.confirmActivation(recoveryId: activationResponse.recoveryId)
        } catch {
            syncedSettingsService[\.accountRecoveryKeyInfo] = nil
            throw error
        }
        syncService.enableSync(triggeredBy: .manual)
    }

     func encryptMasterKey(with accountRecoveryKey: AccountRecoveryKey) throws -> String {
         guard let cryptoCenter = CryptoCenter(from: cryptoConfig.parametersHeader) else {
             throw Error.couldNotEncrypt
         }
        let cryptoEngine = SpecializedCryptoEngine(cryptoCenter: cryptoCenter, secret: .password(accountRecoveryKey))

        guard let valueToEncrypt = masterKey.valueToEncrypt,
              let encryptedData = cryptoEngine.encrypt(data: valueToEncrypt) else {
            throw Error.couldNotEncrypt
        }
         return encryptedData.base64EncodedString()
    }

    func deactivateAccountRecoveryKey(for reason: UserDeviceAPIClient.Accountrecovery.Deactivate.Reason) async throws {
        try await userAPIClient.accountrecovery.deactivate(reason: reason)
        syncedSettingsService[\.accountRecoveryKeyInfo] = nil
        activityReporter.report(UserEvent.DeleteAccountRecoveryKey(deleteKeyReason: reason.logReason))
                Task {
            do {
                try await syncService.syncAndDisable()
            } catch {
                logger.fatal("Account Recovery Key deactivated but settings not synced")
            }
            syncService.enableSync(triggeredBy: .manual)
        }
    }
}

extension AccountRecoveryKeyService {
    static var mock: AccountRecoveryKeyService {
        AccountRecoveryKeyService(login: Login("_"),
                                  cryptoConfig: CryptoRawConfig(fixedSalt: nil, parametersHeader: "$1$argon2d$16$3$32768$2$aes256$cbchmac$16$"),
                                  appAPIClient: .fake,
                                  userAPIClient: .fake,
                                  syncService: SyncServiceMock(),
                                  syncedSettingsService: .mock,
                                  masterKey: .masterPassword("Azerty12"),
                                  logger: LoggerMock(),
                                  activityReporter: .fake)
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

extension UserDeviceAPIClient.Accountrecovery.Deactivate.Reason {
    var logReason: Definition.DeleteKeyReason {
        switch self {
        case .keyUsed:
            return .recoveryKeyUsed
        case .settings:
            return .settingDisabled
        case .vaultKeyChange:
            return .vaultKeyChanged
        }
    }
}
