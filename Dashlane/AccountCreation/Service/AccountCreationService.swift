import AdSupport
import Adjust
import AppTrackingTransparency
import CoreSession
import CoreUserTracking
import DashTypes
import DashlaneAPI
import LoginKit
import UIKit

actor AccountCreationService {
  let sessionsContainer: SessionsContainerProtocol
  let sessionCleaner: SessionCleaner
  let sessionServicesLoader: SessionServicesLoader
  let appAPIClient: AppAPIClient
  let sessionCryptoEngineProvider: SessionCryptoEngineProvider
  let logger: Logger

  public init(
    sessionsContainer: SessionsContainerProtocol,
    sessionCleaner: SessionCleaner,
    sessionServicesLoader: SessionServicesLoader,
    appAPIClient: AppAPIClient,
    sessionCryptoEngineProvider: SessionCryptoEngineProvider,
    logger: Logger
  ) {
    self.sessionsContainer = sessionsContainer
    self.sessionCleaner = sessionCleaner
    self.sessionServicesLoader = sessionServicesLoader
    self.appAPIClient = appAPIClient
    self.sessionCryptoEngineProvider = sessionCryptoEngineProvider
    self.logger = logger
  }

  func createAccountAndLoad(using configuration: AccountCreationConfiguration) async throws
    -> SessionServicesContainer
  {
    do {
      let session = try await createAccount(using: configuration)
      let sessionServices = try await sessionServicesLoader.load(
        for: session, context: .accountCreation)
      sessionServices.activityReporter.logAccountCreationSuccessful()
      sessionServices.apply(configuration.local)
      return sessionServices
    } catch {
      logger.error("Failed to create account", error: error)
      throw error
    }
  }

  private func createAccount(using configuration: AccountCreationConfiguration) async throws
    -> Session
  {
    let sessionCryptoEngine = try sessionCryptoEngineProvider.sessionCryptoEngine(
      for: .masterPassword(configuration.password))
    let cryptoConfig = sessionCryptoEngine.config

    let creationInfo = try AccountCreationInfo(
      email: configuration.email,
      appVersion: Application.version(),
      cryptoEngine: sessionCryptoEngine,
      hasUserAcceptedEmailMarketing: configuration.hasUserAcceptedEmailMarketing,
      origin: .iOS,
      accountType: configuration.accountType)
    let accountInfo = try await appAPIClient.account.createAccount(with: creationInfo)

    let login = Login(creationInfo.login)
    let configuration = SessionConfiguration(
      login: login,
      masterKey: .masterPassword(configuration.password, serverKey: nil),
      keys: SessionSecureKeys(
        serverAuthentication: ServerAuthentication(
          deviceAccessKey: accountInfo.deviceAccessKey, deviceSecretKey: accountInfo.deviceSecretKey
        ),
        remoteKey: nil,
        analyticsIds: AnalyticsIdentifiers(
          device: accountInfo.deviceAnalyticsId, user: accountInfo.userAnalyticsId)),
      info: SessionInfo(
        deviceAccessKey: accountInfo.deviceAccessKey,
        loginOTPOption: nil,
        accountType: try AccountType(configuration.accountType)))

    sessionCleaner.removeLocalData(for: login)
    return try sessionsContainer.createSession(with: configuration, cryptoConfig: cryptoConfig)
  }
}

extension SessionServicesContainer {
  fileprivate func apply(_ localConfiguration: AccountCreationConfiguration.LocalConfiguration) {
    if localConfiguration.isBiometricAuthenticationEnabled {
      try? lockService.secureLockConfigurator.enableBiometry()
    }

    if let pin = localConfiguration.pincode {
      try? lockService.secureLockConfigurator.enablePinCode(pin)
    }

    if case let .masterPassword(masterPassword, _) = session.authenticationMethod {
      if localConfiguration.isMasterPasswordResetEnabled {
        try? resetMasterPasswordService.activate(using: masterPassword)
      }

      if localConfiguration.isRememberMasterPasswordEnabled {
        try? lockService.secureLockConfigurator.enableRememberMasterPassword()
      }
    }
  }
}

extension ActivityReporterProtocol {
  fileprivate func logAccountCreationSuccessful() {
    let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
    let idfv = UIDevice.current.identifierForVendor?.uuidString
    let isMarketingOptIn = ATTrackingManager.trackingAuthorizationStatus == .authorized

    report(
      UserEvent.CreateAccount(
        iosMarketing: .init(adid: Adjust.adid(), idfa: idfa, idfv: idfv),
        isMarketingOptIn: isMarketingOptIn,
        status: .success))
  }
}

extension AppServicesContainer {
  var accountCreationService: AccountCreationService {
    AccountCreationService(
      sessionsContainer: sessionContainer,
      sessionCleaner: sessionCleaner,
      sessionServicesLoader: sessionServicesLoader,
      appAPIClient: appAPIClient,
      sessionCryptoEngineProvider: sessionCryptoEngineProvider,
      logger: rootLogger[.session])
  }
}
