import AutofillKit
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
import VaultKit
import ZXCVBN

@MainActor
class AppServicesContainer: DependenciesContainer {
  let settingsManager: SettingsManager
  let appSettings = AppSettings()
  let appAPIClient: AppAPIClient
  let appExtensionCommunication = AppExtensionCommunicationCenter.init(
    channel: .fromApp, baseURL: ApplicationGroup.documentsURL)
  let rootLogger: Logger
  let remoteLogger: KibanaLogger
  let regionInformationService = try! RegionInformationService()
  let loginMetricsReporter: LoginMetricsReporter
  let passwordEvaluator: PasswordEvaluatorProtocol = PasswordEvaluator()
  let activityReporter: UserTrackingAppActivityReporter
  lazy var domainParser: DomainParserProtocol = try! DomainParser(quickParsing: true)
  lazy var categorizer = try! Categorizer()
  let unauthenticatedABTestingService: UnauthenticatedABTestingService
  let sessionsContainer: SessionsContainerProtocol
  static let crashReporterService = CrashReporterService(target: .tachyon)
  public static let sharedInstance = AppServicesContainer(
    appLaunchTimeStamp: Date().timeIntervalSince1970)
  let keychainService: AuthenticationKeychainService
  let nitroClient: NitroAPIClient
  let sessionCryptoEngineProvider: SessionCryptoEngineProvider
  init(appLaunchTimeStamp: TimeInterval) {
    loginMetricsReporter = LoginMetricsReporter(appLaunchTimeStamp: appLaunchTimeStamp)
    loginMetricsReporter.markAsLoadingSessionFromSavedLogin()
    _ = AppServicesContainer.crashReporterService
    let localLogger = LocalLogger()
    appAPIClient = try! AppAPIClient()
    remoteLogger = try! KibanaLogger(
      apiClient: .init(),
      outputLevel: .fatal,
      origin: .tachyon)

    self.rootLogger = [
      localLogger,
      remoteLogger,
    ]
    settingsManager = SettingsManager(logger: rootLogger[.localSettings])
    sessionCryptoEngineProvider = SessionCryptoEngineProvider(logger: rootLogger)

    sessionsContainer = try! SessionsContainer(
      baseURL: ApplicationGroup.fiberSessionsURL,
      cryptoEngineProvider: sessionCryptoEngineProvider,
      sessionStoreProvider: SessionStoreProvider())

    self.activityReporter = try! UserTrackingAppActivityReporter(
      logger: rootLogger[.userTrackingLogs],
      component: .osAutofill,
      cryptoEngineProvider: sessionCryptoEngineProvider,
      appAPIClient: appAPIClient,
      platform: .current
    )
    self.nitroClient = try! NitroAPIClient()
    unauthenticatedABTestingService = UnauthenticatedABTestingService(
      logger: rootLogger[.abTesting],
      apiClient: appAPIClient,
      testsToEvaluate: UnauthenticatedABTestingService.testsToEvaluate,
      cache: appSettings)

    keychainService = AuthenticationKeychainService(
      cryptoEngineProvider: sessionCryptoEngineProvider,
      keychainSettingsDataProvider: settingsManager,
      accessGroup: ApplicationGroup.keychainAccessGroup)
    updateDefaultReportAction()
  }

  @MainActor
  private func updateDefaultReportAction() {
    ReportActionKey.defaultValue = ReportAction(reporter: activityReporter)
  }
}

extension AppServicesContainer {
  var personalDataURLDecoder: PersonalDataURLDecoder {
    PersonalDataURLDecoder(domainParser: domainParser)
  }
}
extension AppServicesContainer {
  var sessionCleaner: SessionCleaner {
    SessionCleaner(
      keychainService: keychainService, sessionsContainer: sessionsContainer,
      logger: rootLogger[.session])
  }
}

extension LoginKitServicesContainer: AppServicesInjecting {}
