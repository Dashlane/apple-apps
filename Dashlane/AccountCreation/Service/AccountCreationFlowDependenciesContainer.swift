import CoreKeychain
import CorePasswords
import CoreSession
import CoreTypes
import CoreUserTracking
import DashlaneAPI
import Foundation
import LogFoundation
import UserTrackingFoundation

protocol AccountCreationFlowDependenciesContainer: DependenciesContainer {
  var appAPIClient: AppAPIClient { get }
  var nitroClient: NitroSSOAPIClient { get }
  var logger: Logger { get }
  var activityReporter: ActivityReporterProtocol { get }
  var passwordEvaluator: PasswordEvaluatorProtocol { get }
  var userCountryProvider: UserCountryProvider { get }
  var accountCreationService: RegularAccountCreationService { get }
}
