import CoreCategorizer
import CoreKeychain
import CorePersonalData
import CoreSession
import CoreUserTracking
import DashTypes
import DomainParser
import Foundation
import IconLibrary

public protocol AuthenticatorServicesContainer: DependenciesContainer {
  var databaseService: AuthenticatorDatabaseServiceProtocol { get }
  var authenticatorActivityReporter: ActivityReporterProtocol { get }
  var authenticatorCategorizer: CategorizerProtocol { get }
  var domainIconLibrary: DomainIconLibraryProtocol { get }
  var logger: Logger { get }
  var domainParser: DomainParserProtocol { get }
  var keychainService: AuthenticationKeychainServiceProtocol { get }
  var sessionsContainer: SessionsContainerProtocol { get }
}
