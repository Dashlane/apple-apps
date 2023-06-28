import Foundation
import DashTypes
import CoreUserTracking
import CorePersonalData
import CoreCategorizer
import IconLibrary
import DomainParser
import CoreKeychain
import CoreSession

public protocol AuthenticatorServicesContainer: DependenciesContainer {
    var databaseService: AuthenticatorDatabaseServiceProtocol { get }
    var authenticatorActivityReporter: ActivityReporterProtocol { get }
    var authenticatorCategorizer: CategorizerProtocol { get }
    var domainIconLibrary: DomainIconLibraryProtocol { get }
    var logger: Logger { get }
    var domainParser: DomainParserProtocol { get }
    var keychainService: AuthenticationKeychainServiceProtocol { get }
    var legacyWebservice: LegacyWebService { get }
    var sessionsContainer: SessionsContainerProtocol { get }
}
