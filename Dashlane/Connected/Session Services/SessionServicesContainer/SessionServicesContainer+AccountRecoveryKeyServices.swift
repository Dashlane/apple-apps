import Foundation

extension SessionServicesContainer {
    var accountRecoveryKeyService: AccountRecoveryKeyService {
        AccountRecoveryKeyService(login: session.login,
                                  cryptoConfig: session.cryptoEngine.config,
                                  appAPIClient: appServices.appAPIClient,
                                  userAPIClient: userDeviceAPIClient,
                                  syncService: syncService,
                                  syncedSettingsService: syncedSettings,
                                  masterKey: session.authenticationMethod.sessionKey,
                                  logger: logger,
                                  activityReporter: activityReporter)
    }
}
