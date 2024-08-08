import AuthenticatorKit
import CoreCategorizer
import CoreKeychain
import CoreSession
import CoreUserTracking
import DashTypes
import DomainParser
import Foundation

extension PairedServicesContainer: AuthenticatorServicesContainer {
  var authenticatorActivityReporter: ActivityReporterProtocol {
    appServices.activityReporter
  }

  var authenticatorCategorizer: CategorizerProtocol {
    appServices.categorizer
  }

  var logger: Logger {
    appServices.rootLogger
  }

  var domainParser: DomainParserProtocol {
    appServices.domainParser
  }

  var keychainService: AuthenticationKeychainServiceProtocol {
    appServices.keychainService
  }

  var sessionsContainer: SessionsContainerProtocol {
    appServices.sessionsContainer
  }
}
