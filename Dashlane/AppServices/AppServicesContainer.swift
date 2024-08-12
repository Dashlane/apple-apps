import AuthenticatorKit
import CoreCategorizer
import CoreFeature
import CoreKeychain
import CoreNetworking
import CorePasswords
import CorePersonalData
import CoreSession
import CoreSettings
import CoreUserTracking
import DashTypes
import DashlaneAPI
import DomainParser
import Foundation
import Logger
import LoginKit
import NotificationKit
import SwiftTreats
import VaultKit
import ZXCVBN

final class AppServicesContainer: DependenciesContainer {
  let appAPIClient: AppAPIClient
  let nitroClient: NitroAPIClient
  let sessionCryptoEngineProvider: SessionCryptoEngineProvider
  let sessionContainer: SessionsContainerProtocol
  let rootLogger: Logger
  let remoteLogger: KibanaLogger
  let domainParser: DomainParserProtocol
  let categorizer: Categorizer
  let regionInformationService: RegionInformationService
  let globalSettings = AppSettings()
  let keychainService: AuthenticationKeychainService
  weak var sessionLifeCycleHandler: SessionLifeCycleHandler?
  let passwordEvaluator: PasswordEvaluatorProtocol
  let crashReporter: CrashReporterService
  let notificationService: NotificationService
  let deepLinkingService: DeepLinkingService
  let loginMetricsReporter: LoginMetricsReporter
  let networkReachability: NetworkReachability
  let unauthenticatedABTestingService: UnauthenticatedABTestingService
  let spotlightIndexer: SpotlightIndexer
  let spiegelSettingsManager: SettingsManager
  let activityReporter: UserTrackingAppActivityReporter
  let versionValidityService: VersionValidityService
  #if targetEnvironment(macCatalyst)
    let appKitBridge: AppKitBridgeProtocol
  #endif
  let brazeService: BrazeServiceProtocol

  @MainActor
  init(
    sessionLifeCycleHandler: SessionLifeCycleHandler,
    crashReporter: CrashReporterService,
    appLaunchTimeStamp: TimeInterval
  ) throws {
    self.crashReporter = crashReporter
    globalSettings.configure()

    var url = ApplicationGroup.containerURL
    try? url.setExcludedFromiCloudBackup()

    let localLogger = LocalLogger()
    self.appAPIClient = try AppAPIClient()
    self.nitroClient = try NitroAPIClient()
    networkReachability = NetworkReachability()

    remoteLogger = try KibanaLogger(
      apiClient: .init(),
      outputLevel: .fatal,
      origin: .mainApplication)

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

    sessionContainer = try SessionsContainer(
      baseURL: ApplicationGroup.fiberSessionsURL,
      cryptoEngineProvider: sessionCryptoEngineProvider,
      sessionStoreProvider: SessionStoreProvider())

    activityReporter = try UserTrackingAppActivityReporter(
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
    loginMetricsReporter = LoginMetricsReporter(appLaunchTimeStamp: appLaunchTimeStamp)

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
      activityReporter: activityReporter)
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

extension LoginKitServicesContainer: AppServicesInjecting {

}

extension AppServicesContainer: AccountCreationFlowDependenciesContainer {
  var logger: DashTypes.Logger {
    rootLogger
  }
}
