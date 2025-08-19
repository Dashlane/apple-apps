import AuthenticatorKit
import AutofillKit
import CoreCategorizer
import CoreFeature
import CoreKeychain
import CoreNetworking
import CorePasswords
import CorePersonalData
import CoreSession
import CoreSettings
import CoreTypes
import CoreUserTracking
import DashlaneAPI
import DomainParser
import Foundation
import LogFoundation
import Logger
import LoginKit
import NotificationKit
import SwiftTreats
import UserTrackingFoundation
import VaultKit
import ZXCVBN

final class AppServicesContainer: DependenciesContainer {
  let appAPIClient: AppAPIClient
  let nitroClient: NitroSSOAPIClient
  let sessionCryptoEngineProvider: SessionCryptoEngineProvider
  let sessionContainer: SessionsContainerProtocol
  let rootLogger: Logger
  let remoteLogger: KibanaLogger
  let domainParser: DomainParserProtocol
  let categorizer: Categorizer
  let regionInformationService: RegionInformationService
  let globalSettings = AppSettings()
  let keychainService: AuthenticationKeychainServiceProtocol
  weak var sessionLifeCycleHandler: SessionLifeCycleHandler?
  let passwordEvaluator: PasswordEvaluatorProtocol
  let crashReporter: CrashReporter
  let notificationService: NotificationService
  let deepLinkingService: DeepLinkingService
  let networkReachability: NetworkReachabilityProtocol
  let unauthenticatedABTestingService: UnauthenticatedABTestingService
  let spotlightIndexer: SpotlightIndexer
  let spiegelSettingsManager: SettingsManager
  let userTrackingAppActivityReporter: UserTrackingAppActivityReporter
  let versionValidityService: VersionValidityService
  let autofillExtensionCommunicationCenter = AppAutofillExtensionCommunicationCenter()
  #if targetEnvironment(macCatalyst)
    let appKitBridge: AppKitBridgeProtocol
  #endif
  let brazeService: BrazeServiceProtocol

  @MainActor
  init(
    sessionLifeCycleHandler: SessionLifeCycleHandler,
    crashReporter: CrashReporter,
    appLaunchTimeStamp: TimeInterval
  ) async throws {
    self.crashReporter = crashReporter
    globalSettings.configure()

    var url = ApplicationGroup.containerURL
    try? url.setExcludedFromiCloudBackup()

    let localLogger = LocalLogger()
    self.appAPIClient = try AppAPIClient()
    self.nitroClient = try NitroSSOAPIClient()
    networkReachability = NetworkReachability()

    remoteLogger = try KibanaLogger(
      apiClient: .init(),
      outputLevel: .fatal,
      origin: .mainApplication,
      deviceId: globalSettings.deviceId)

    rootLogger = [
      localLogger,
      remoteLogger,
    ]
    spiegelSettingsManager = SettingsManager(logger: rootLogger)

    domainParser = DomainParserContainer()
    categorizer = try Categorizer()
    regionInformationService = try RegionInformationService()

    sessionCryptoEngineProvider = SessionCryptoEngineProvider(logger: rootLogger)

    keychainService = AuthenticationKeychainService(
      cryptoEngineProvider: sessionCryptoEngineProvider,
      keychainSettingsDataProvider: spiegelSettingsManager,
      accessGroup: ApplicationGroup.keychainAccessGroup)

    sessionContainer = try await SessionsContainer(
      baseURL: ApplicationGroup.fiberSessionsURL,
      cryptoEngineProvider: sessionCryptoEngineProvider,
      sessionStoreProvider: SessionStoreProvider())

    userTrackingAppActivityReporter = try UserTrackingAppActivityReporter(
      logger: rootLogger[.userTrackingLogs],
      component: .mainApp,
      cryptoEngineProvider: sessionCryptoEngineProvider,
      appAPIClient: appAPIClient,
      platform: .current
    )
    passwordEvaluator = PasswordEvaluator()
    self.brazeService = BrazeService(logger: rootLogger)
    notificationService = NotificationService(logger: rootLogger[.remoteNotifications])
    self.deepLinkingService = DeepLinkingService(
      sessionLifeCycleHandler: sessionLifeCycleHandler, notificationService: notificationService,
      brazeService: brazeService)
    self.sessionLifeCycleHandler = sessionLifeCycleHandler

    spotlightIndexer = SpotlightIndexer(logger: rootLogger[.spotlight])
    unauthenticatedABTestingService = UnauthenticatedABTestingService(
      logger: rootLogger[.abTesting],
      apiClient: appAPIClient,
      testsToEvaluate: UnauthenticatedABTestingService.testsToEvaluate,
      cache: globalSettings)
    versionValidityService = VersionValidityService(
      apiClient: appAPIClient,
      appSettings: globalSettings,
      logoutHandler: sessionLifeCycleHandler,
      logger: rootLogger[.versionValidity],
      activityReporter: userTrackingAppActivityReporter)

    #if targetEnvironment(macCatalyst)
      appKitBridge = AppKitBundleLoader.load()
    #endif
    updateDefaultReportAction()
  }

  @MainActor
  private func updateDefaultReportAction() {
    ReportActionKey.defaultValue = ReportAction(reporter: activityReporter)
  }
}

extension AppServicesContainer {
  var personalDataURLDecoder: PersonalDataURLDecoderProtocol {
    PersonalDataURLDecoder(domainParser: domainParser)
  }
}

extension AppServicesContainer: LoginKitServicesContainer {
  var activityReporter: UserTrackingFoundation.ActivityReporterProtocol {
    userTrackingAppActivityReporter
  }

  var cryptoEngineProvider: any CoreSession.CryptoEngineProvider {
    sessionCryptoEngineProvider
  }

  var settingsManager: any CoreSettings.LocalSettingsFactory {
    spiegelSettingsManager
  }
}

extension AppServicesContainer: AccountCreationFlowDependenciesContainer {

  var logger: LogFoundation.Logger {
    rootLogger
  }
}

extension AppServicesContainer {
  var accountCreationFlowStateMachine: AccountCreationStateMachine {
    return CoreSession.AccountCreationStateMachine(
      logger: logger,
      appAPIClient: appAPIClient,
      sessionCleaner: sessionCleaner,
      sessionContainer: sessionContainer,
      passwordGenerator: PasswordGenerator(length: 40, composition: .all, distinguishable: false),
      sessionCryptoEngineProvider: sessionCryptoEngineProvider,
      accountCreationSettingsProvider: self,
      accountCreationSharingKeysProvider: self)
  }
}
