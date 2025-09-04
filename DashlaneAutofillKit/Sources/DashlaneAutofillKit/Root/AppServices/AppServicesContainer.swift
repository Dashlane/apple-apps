import AuthenticationServices
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
import UserTrackingFoundation
import VaultKit
import ZXCVBN

@MainActor
class AppServicesContainer: DependenciesContainer {
  let spiegelSettingsManager: SettingsManager
  let appSettings = AppSettings()
  let appAPIClient: AppAPIClient
  let appExtensionCommunication = AppAutofillExtensionCommunicationCenter()
  let rootLogger: Logger
  let remoteLogger: KibanaLogger
  let regionInformationService: RegionInformationService
  let passwordEvaluator: PasswordEvaluatorProtocol = PasswordEvaluator()
  let userTrackingAppActivityReporter: UserTrackingAppActivityReporter
  let deeplinkingService: DeepLinkingServiceProtocol
  lazy var domainParser: DomainParserProtocol = try! DomainParser(quickParsing: true)
  lazy var categorizer = try! Categorizer()
  let unauthenticatedABTestingService: UnauthenticatedABTestingService
  let sessionContainer: SessionsContainerProtocol
  let crashReporterService = SentryCrashReporter(target: .tachyon)
  public static func sharedInstance() async -> AppServicesContainer {
    await AppServicesContainer(
      appLaunchTimeStamp: Date().timeIntervalSince1970,
      context: ASCredentialProviderExtensionContext())
  }
  let keychainService: AuthenticationKeychainServiceProtocol
  let nitroClient: NitroSSOAPIClient
  let sessionCryptoEngineProvider: SessionCryptoEngineProvider

  init(appLaunchTimeStamp: TimeInterval, context: ASCredentialProviderExtensionContext) async {
    let localLogger = LocalLogger()
    appAPIClient = try! AppAPIClient()
    remoteLogger = try! KibanaLogger(
      apiClient: .init(),
      outputLevel: .fatal,
      origin: .tachyon,
      deviceId: appSettings.deviceId)

    self.rootLogger = [
      localLogger,
      remoteLogger,
    ]
    spiegelSettingsManager = SettingsManager(logger: rootLogger[.localSettings])
    sessionCryptoEngineProvider = SessionCryptoEngineProvider(logger: rootLogger)

    sessionContainer = try! await SessionsContainer(
      baseURL: ApplicationGroup.fiberSessionsURL,
      cryptoEngineProvider: sessionCryptoEngineProvider,
      sessionStoreProvider: SessionStoreProvider())

    self.regionInformationService = try! RegionInformationService()
    self.userTrackingAppActivityReporter = try! UserTrackingAppActivityReporter(
      logger: rootLogger[.userTrackingLogs],
      component: .osAutofill,
      cryptoEngineProvider: sessionCryptoEngineProvider,
      appAPIClient: appAPIClient,
      platform: .current
    )
    self.nitroClient = try! NitroSSOAPIClient()
    unauthenticatedABTestingService = UnauthenticatedABTestingService(
      logger: rootLogger[.abTesting],
      apiClient: appAPIClient,
      testsToEvaluate: UnauthenticatedABTestingService.testsToEvaluate,
      cache: appSettings)

    keychainService = AuthenticationKeychainService(
      cryptoEngineProvider: sessionCryptoEngineProvider,
      keychainSettingsDataProvider: spiegelSettingsManager,
      accessGroup: ApplicationGroup.keychainAccessGroup)

    deeplinkingService = TachyonDeeplinkingService(context: context)

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

  var activityReporter: ActivityReporterProtocol {
    userTrackingAppActivityReporter
  }
}
extension AppServicesContainer {
  var sessionCleaner: SessionCleanerProtocol {
    SessionCleaner(
      keychainService: keychainService, sessionsContainer: sessionContainer,
      logger: rootLogger[.session])
  }
}

extension AppServicesContainer: LoginKitServicesContainer {

  var cryptoEngineProvider: any CoreSession.CryptoEngineProvider {
    sessionCryptoEngineProvider
  }

  var settingsManager: any CoreSettings.LocalSettingsFactory {
    spiegelSettingsManager
  }
}
