import Foundation

extension SessionServicesContainer {
  var accountRecoveryKeyService: AccountRecoveryKeySetupService {
    AccountRecoveryKeySetupService(
      login: session.login,
      cryptoConfig: session.cryptoEngine.config,
      cryptoEngineProvider: appServices.sessionCryptoEngineProvider,
      appAPIClient: appServices.appAPIClient,
      userAPIClient: userDeviceAPIClient,
      syncService: syncService,
      syncedSettingsService: syncedSettings,
      masterKey: session.authenticationMethod.sessionKey,
      logger: logger,
      activityReporter: activityReporter)
  }
}
