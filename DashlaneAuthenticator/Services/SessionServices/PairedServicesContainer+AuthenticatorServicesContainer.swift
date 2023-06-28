import Foundation
import AuthenticatorKit
import CoreCategorizer
import DomainParser
import DashTypes
import CoreUserTracking
import CoreKeychain
import CoreSession

extension PairedServicesContainer: AuthenticatorServicesContainer {
    var authenticatorActivityReporter: ActivityReporterProtocol {
        appServices.activityReporter
    }

    var authenticatorCategorizer: CategorizerProtocol {
        appServices.categorizer
    }

    var logger: Logger {
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
