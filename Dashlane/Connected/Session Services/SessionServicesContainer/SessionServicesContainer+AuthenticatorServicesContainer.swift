import AuthenticatorKit
import CoreCategorizer
import CoreKeychain
import CoreSession
import CoreUserTracking
import DashTypes
import DomainParser
import Foundation
import IconLibrary

extension SessionServicesContainer: AuthenticatorServicesContainer {
  var domainParser: DomainParserProtocol {
    appServices.domainParser
  }

  var keychainService: CoreKeychain.AuthenticationKeychainServiceProtocol {
    appServices.keychainService
  }

  var sessionsContainer: CoreSession.SessionsContainerProtocol {
    appServices.sessionContainer
  }

  var databaseService: AuthenticatorKit.AuthenticatorDatabaseServiceProtocol {
    otpDatabaseService
  }

  var authenticatorActivityReporter: CoreUserTracking.ActivityReporterProtocol {
    self.activityReporter
  }

  var authenticatorCategorizer: CoreCategorizer.CategorizerProtocol {
    self.appServices.categorizer
  }

  var domainIconLibrary: DomainIconLibraryProtocol {
    self.iconService.domain
  }

  var logger: DashTypes.Logger {
    self.rootLogger
  }
}
