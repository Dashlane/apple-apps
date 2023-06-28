import Foundation
import CorePasswords
import CoreCategorizer
import CorePersonalData
import DashTypes
import DomainParser
import DashlaneAppKit
import CoreSettings

struct AutofillAppServicesContainer {
    let communicationService: MainApplicationCommunicationServiceProtocol
    let passwordEvaluator: PasswordEvaluatorProtocol
    let domainParser: DomainParser
    let regionInformationService: RegionInformationService
    let personalDataURLDecoder: PersonalDataURLDecoderProtocol
    let logger: Logger
    let appSettings: AppSettings
    let nonAuthenticatedWebService: LegacyWebService
}
