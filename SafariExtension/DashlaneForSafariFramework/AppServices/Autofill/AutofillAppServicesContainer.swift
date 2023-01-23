import Foundation
import CorePasswords
import CoreCategorizer
import DashTypes
import DashlaneReportKit
import DomainParser
import DashlaneAppKit

struct AutofillAppServicesContainer {
    let communicationService: MainApplicationCommunicationServiceProtocol
    let passwordEvaluator: PasswordEvaluatorProtocol
    let domainParser: DomainParser
    let regionInformationService: RegionInformationService
    let personalDataURLDecoder: PersonalDataURLDecoder
    let logger: Logger
    let appSettings: AppSettings
    let nonAuthenticatedWebService: LegacyWebService
    let logEngine: LogEngine
}
