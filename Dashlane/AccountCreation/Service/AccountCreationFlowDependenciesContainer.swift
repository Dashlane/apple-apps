import Foundation
import DashTypes
import DashlaneAPI
import CoreSession
import CoreUserTracking
import CorePasswords
import CoreKeychain

protocol AccountCreationFlowDependenciesContainer: DependenciesContainer {
    var appAPIClient: AppAPIClient { get }
    var logger: Logger { get }
    var activityReporter: UserTrackingAppActivityReporter { get }
    var passwordEvaluator: PasswordEvaluatorProtocol { get }
    var userCountryProvider: UserCountryProvider { get }
    var accountCreationService: AccountCreationService { get }
}
