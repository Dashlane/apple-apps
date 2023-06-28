import Foundation
import AuthenticatorKit
import CoreUserTracking
import CoreCategorizer
import DashTypes
import IconLibrary
import DomainParser
import CoreKeychain
import CoreSession

extension SessionServicesContainer: AuthenticatorServicesContainer {
    var domainParser: DomainParserProtocol {
        appServices.domainParser
    }

    var keychainService: CoreKeychain.AuthenticationKeychainServiceProtocol {
        appServices.keychainService
    }

    var legacyWebservice: DashTypes.LegacyWebService {
        appServices.nonAuthenticatedUKIBasedWebService
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
