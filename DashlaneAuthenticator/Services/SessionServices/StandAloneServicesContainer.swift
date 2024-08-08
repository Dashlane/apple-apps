import AuthenticatorKit
import CoreCategorizer
import CoreKeychain
import CoreSession
import CoreUserTracking
import DashTypes
import DomainParser
import Foundation
import IconLibrary
import Logger

class StandAloneServicesContainer: DependenciesContainer {
  public let appServices: AppServices
  public let databaseService: AuthenticatorDatabaseServiceProtocol
  public let domainIconLibrary: DomainIconLibraryProtocol

  init(appServices: AppServices) {
    self.appServices = appServices
    databaseService = AuthenticatorDatabaseService(
      logger: appServices.rootLogger[.localCommunication])
    domainIconLibrary = DomainIconLibrary(
      appAPIClient: appServices.appAPIClient, logger: appServices.rootLogger[.iconLibrary])
  }
}

extension StandAloneServicesContainer: AuthenticatorServicesContainer {
  var authenticatorActivityReporter: ActivityReporterProtocol {
    appServices.activityReporter
  }

  var authenticatorCategorizer: CategorizerProtocol {
    appServices.categorizer
  }

  var logger: DashTypes.Logger {
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
