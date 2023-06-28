import Foundation
import DashTypes

extension SessionServicesContainer {
    func makeAccountCryptoChangerService(newMasterPassword: String) throws -> AccountCryptoChangerService {
        let cryptoConfig = CryptoRawConfig.masterPasswordBasedDefault
        let currentMasterKey = session.authenticationMethod.sessionKey

        let migratingSession = try sessionsContainer.prepareMigration(of: session,
                                                                      to: .masterPassword(newMasterPassword, serverKey: currentMasterKey.serverKey),
                                                                      remoteKey: nil,
                                                                      cryptoConfig: cryptoConfig,
                                                                      accountMigrationType: .masterPasswordToMasterPassword,
                                                                      loginOTPOption: session.configuration.info.loginOTPOption)

        let postCryptoChangeHandler = PostMasterKeyChangerHandler(keychainService: keychainService,
                                                                  resetMasterPasswordService: resetMasterPasswordService,
                                                                  syncService: syncService)

        return try AccountCryptoChangerService(reportedType: .masterPasswordChange,
                                               migratingSession: migratingSession,
                                               syncService: syncService,
                                               sessionCryptoUpdater: sessionCryptoUpdater,
                                               activityReporter: activityReporter,
                                               sessionsContainer: sessionsContainer,
                                               databaseDriver: databaseDriver,
                                               postCryptoChangeHandler: postCryptoChangeHandler,
                                               apiNetworkingEngine: userDeviceAPIClient,
                                               logger: logger,
                                               cryptoSettings: cryptoConfig)
    }
}
