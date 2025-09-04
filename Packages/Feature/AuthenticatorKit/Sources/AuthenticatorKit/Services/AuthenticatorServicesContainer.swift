import CoreCategorizer
import CoreKeychain
import CorePersonalData
import CoreSession
import CoreTypes
import DomainParser
import Foundation
import IconLibrary
import LogFoundation
import UserTrackingFoundation

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
