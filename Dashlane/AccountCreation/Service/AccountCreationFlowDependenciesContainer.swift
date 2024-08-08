import CoreKeychain
import CorePasswords
import CoreSession
import CoreUserTracking
import DashTypes
import DashlaneAPI
import Foundation

protocol AccountCreationFlowDependenciesContainer: DependenciesContainer {
  var appAPIClient: AppAPIClient { get }
  var logger: Logger { get }
  var activityReporter: UserTrackingAppActivityReporter { get }
  var passwordEvaluator: PasswordEvaluatorProtocol { get }
  var userCountryProvider: UserCountryProvider { get }
  var accountCreationService: AccountCreationService { get }
}
