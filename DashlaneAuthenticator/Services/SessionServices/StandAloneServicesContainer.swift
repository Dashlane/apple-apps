import Foundation
import Logger
import AuthenticatorKit
import DashTypes
import IconLibrary
import CoreUserTracking
import CoreCategorizer
import DomainParser
import CoreKeychain
import CoreSession

class StandAloneServicesContainer: DependenciesContainer {
    public let appServices: AppServices
    public let databaseService: AuthenticatorDatabaseServiceProtocol
    public let domainIconLibrary: DomainIconLibraryProtocol

    init(appServices: AppServices) {
        self.appServices = appServices
        databaseService = AuthenticatorDatabaseService(logger: appServices.rootLogger[.localCommunication])
        domainIconLibrary = DomainIconLibrary(webService: appServices.nonAuthenticatedUKIBasedWebService, logger: appServices.rootLogger[.iconLibrary])
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

    var legacyWebservice: LegacyWebService {
        appServices.nonAuthenticatedUKIBasedWebService
    }

    var sessionsContainer: SessionsContainerProtocol {
        appServices.sessionsContainer
    }
}
