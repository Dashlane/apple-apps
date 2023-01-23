import Foundation
import DashTypes
import AuthenticatorKit
import IconLibrary

protocol AuthenticatorServicesContainer: DependenciesContainer {
    var appServices: AppServices { get }
    var databaseService: AuthenticatorDatabaseServiceProtocol { get }
    var domainIconLibrary: DomainIconLibraryProtocol { get }
}

extension TokenListViewModel: AuthenticatorServicesInjecting { }
