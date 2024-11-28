import CoreKeychain
import CoreNetworking
import CorePasswords
import CoreSession
import CoreSettings
import CoreUserTracking
import DashTypes
import DashlaneAPI
import Foundation
import Logger

public struct LoginKitServicesContainer: DependenciesContainer {
  public let loginMetricsReporter: LoginMetricsReporterProtocol
  public let activityReporter: ActivityReporterProtocol
  public let keychainService: AuthenticationKeychainServiceProtocol
  public let sessionCleaner: SessionCleaner
  public let sessionCryptoEngineProvider: CryptoEngineProvider
  public let sessionContainer: SessionsContainerProtocol
  public let rootLogger: Logger
  public let settingsManager: LocalSettingsFactory
  public let appAPIClient: AppAPIClient
  public let nitroClient: NitroSSOAPIClient
  public let passwordEvaluator: PasswordEvaluatorProtocol

  public init(
    loginMetricsReporter: LoginMetricsReporterProtocol,
    activityReporter: ActivityReporterProtocol,
    sessionCleaner: SessionCleaner,
    settingsManager: LocalSettingsFactory,
    keychainService: AuthenticationKeychainServiceProtocol,
    appAPIClient: AppAPIClient,
    sessionCryptoEngineProvider: CryptoEngineProvider,
    sessionContainer: SessionsContainerProtocol,
    rootLogger: Logger,
    nitroClient: NitroSSOAPIClient,
    passwordEvaluator: PasswordEvaluatorProtocol
  ) {
    self.loginMetricsReporter = loginMetricsReporter
    self.settingsManager = settingsManager
    self.activityReporter = activityReporter
    self.keychainService = keychainService
    self.sessionCleaner = sessionCleaner
    self.appAPIClient = appAPIClient
    self.sessionCryptoEngineProvider = sessionCryptoEngineProvider
    self.sessionContainer = sessionContainer
    self.rootLogger = rootLogger
    self.nitroClient = nitroClient
    self.passwordEvaluator = passwordEvaluator
  }
}
