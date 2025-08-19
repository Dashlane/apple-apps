import AuthenticatorKit
import CoreCategorizer
import CoreKeychain
import CoreSession
import CoreTypes
import DomainParser
import Foundation
import IconLibrary
import LogFoundation
import UserTrackingFoundation

extension SessionServicesContainer: AuthenticatorServicesContainer {
  var domainParser: DomainParserProtocol {
    appServices.domainParser
  }

  var keychainService: AuthenticationKeychainServiceProtocol {
    appServices.keychainService
  }

  var sessionsContainer: CoreSession.SessionsContainerProtocol {
    appServices.sessionContainer
  }

  var databaseService: AuthenticatorKit.AuthenticatorDatabaseServiceProtocol {
    otpDatabaseService
  }

  var authenticatorActivityReporter: UserTrackingFoundation.ActivityReporterProtocol {
    self.activityReporter
  }

  var authenticatorCategorizer: CoreCategorizer.CategorizerProtocol {
    self.appServices.categorizer
  }

  var domainIconLibrary: DomainIconLibraryProtocol {
    self.iconService.domain
  }

  var logger: LogFoundation.Logger {
    self.rootLogger
  }
}
