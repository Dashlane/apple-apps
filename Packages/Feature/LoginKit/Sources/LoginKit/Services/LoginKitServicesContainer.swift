import CoreKeychain
import CoreNetworking
import CorePasswords
import CoreSession
import CoreSettings
import CoreTypes
import CoreUserTracking
import DashlaneAPI
import Foundation
import LogFoundation
import Logger
import UserTrackingFoundation

public protocol LoginKitServicesContainer: DependenciesContainer {
  var activityReporter: ActivityReporterProtocol { get }
  var keychainService: AuthenticationKeychainServiceProtocol { get }
  var sessionCleaner: SessionCleanerProtocol { get }
  var cryptoEngineProvider: CryptoEngineProvider { get }
  var sessionContainer: SessionsContainerProtocol { get }
  var rootLogger: Logger { get }
  var settingsManager: LocalSettingsFactory { get }
  var appAPIClient: AppAPIClient { get }
  var nitroClient: NitroSSOAPIClient { get }
  var passwordEvaluator: PasswordEvaluatorProtocol { get }
}
