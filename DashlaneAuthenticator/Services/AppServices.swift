import Combine
import CoreCategorizer
import CoreKeychain
import CoreNetworking
import CorePersonalData
import CoreSession
import CoreSettings
import CoreSync
import CoreUserTracking
import DashTypes
import DashlaneAPI
import DomainParser
import Foundation
import IconLibrary
import Logger
import LoginKit
import SwiftTreats
import VaultKit

public class AppServices: DependenciesContainer {
  let applicationState: ApplicationStateService
  let notificationService: NotificationService
  let appAPIClient: AppAPIClient
  let ipcService: PasswordAppCommunicator
  let spiegelSettingsManager: SettingsManager
  let keychainService: AuthenticationKeychainService
  let rootLogger: Logger
  let remoteLogger: KibanaLogger
  let regionInformationService = try! RegionInformationService()
  let domainParser: DomainParserProtocol = DomainParserContainer()
  let categorizer: Categorizer = try! Categorizer()
  let activityReporter: ActivityReporterProtocol
  let crashReporterService: CrashReporterService
  let sessionsContainer: SessionsContainerProtocol
  let ratingService: RatingService

  init() {
    self.crashReporterService = CrashReporterService(target: .authenticator)
    let localLogger = LocalLogger()

    self.appAPIClient = try! AppAPIClient(platform: .authenticator)

    remoteLogger = try! KibanaLogger(
      apiClient: .init(platform: .authenticator),
      outputLevel: .fatal,
      origin: .authenticator)
    self.rootLogger = [
      localLogger,
      remoteLogger,
    ]
    let cryptoProvider = SessionCryptoEngineProvider(logger: rootLogger)

    activityReporter = try! UserTrackingAppActivityReporter(
      logger: rootLogger[.userTrackingLogs],
      component: .mainApp,
      installationId: UserTrackingAppActivityReporter.authenticatorAnalyticsInstallationId,
      localStorageURL: ApplicationGroup.authenticatorLogsLocalStoreURL,
      cryptoEngineProvider: cryptoProvider,
      appAPIClient: appAPIClient,
      platform: .authenticatorIos
    )

    sessionsContainer = try! SessionsContainer(
      baseURL: ApplicationGroup.fiberSessionsURL,
      cryptoEngineProvider: cryptoProvider,
      sessionStoreProvider: SessionStoreProvider())

    self.notificationService = NotificationService(
      apiClient: appAPIClient, sessionsContainer: sessionsContainer,
      activityReporter: activityReporter)

    spiegelSettingsManager = SettingsManager(logger: rootLogger[.localSettings])
    keychainService = AuthenticationKeychainService(
      cryptoEngineProvider: cryptoProvider,
      keychainSettingsDataProvider: spiegelSettingsManager,
      accessGroup: ApplicationGroup.keychainAccessGroup)

    self.applicationState = ApplicationStateService(
      sessionsContainer: sessionsContainer, keychainService: keychainService,
      logger: rootLogger[.localCommunication], settingsManager: spiegelSettingsManager)
    ipcService = PasswordAppCommunicator(
      logger: rootLogger[.localCommunication], appState: applicationState)
    ratingService = RatingService()
  }
}

extension AppServices {
  var personalDataURLDecoder: PersonalDataURLDecoderProtocol {
    PersonalDataURLDecoder(domainParser: domainParser)
  }
}
