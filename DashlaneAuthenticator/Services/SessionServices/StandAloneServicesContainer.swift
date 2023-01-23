import Foundation
import Logger
import AuthenticatorKit
import DashTypes
import IconLibrary

class StandAloneServicesContainer: DependenciesContainer, AuthenticatorServicesContainer {
    public let appServices: AppServices
    public let databaseService: AuthenticatorDatabaseServiceProtocol
    public let domainIconLibrary: DomainIconLibraryProtocol
    
    init(appServices: AppServices) {
        self.appServices = appServices
        databaseService = AuthenticatorDatabaseService(logger: appServices.rootLogger.sublogger(for: AppLoggerIdentifier.authenticator))
        domainIconLibrary = DomainIconLibrary(webService: appServices.nonAuthenticatedUKIBasedWebService, logger: appServices.rootLogger[.iconLibrary])
    }
}
