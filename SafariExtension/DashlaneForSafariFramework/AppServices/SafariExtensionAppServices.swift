import Foundation
import DashTypes
import Cocoa
import CoreNetworking
import CoreRegion
import CoreCategorizer
import CorePersonalData
import DomainParser
import CoreSettings
import CoreSession
import CorePasswords
import SafariServices
import DashlaneCrypto
import CoreFeature
import Logger
import DashlaneAppKit
import SwiftTreats
import CoreKeychain
import LoginKit
import CoreUserTracking
import VaultKit

class SafariExtensionAppServices: DependenciesContainer {
    
    let sessionSharing: MainApplicationSessionSharing
    let communicationService: MainApplicationCommunicationServiceProtocol
    let activityReporter: UserTrackingAppActivityReporter
    let nonAuthenticatedUKIBasedWebService: LegacyWebService
    let appAPIClient: AppAPIClient

    let regionInformationService: RegionInformationService
    let categorizer: Categorizer
    let personalDataURLDecoder: PersonalDataURLDecoderProtocol
    let rootLogger: Logger
    let remoteLogger: KibanaLogger
    let crashReporterService: CrashReporterService
    let domainParser: DomainParser
    let linkedDomainService: LinkedDomainService
    let globalSettings = AppSettings()
    let spiegelSettingsManager: SettingsManager
    let passwordEvaluator: PasswordEvaluatorProtocol
    let safariExtensionService: SafariExtensionService
    let keychainService: AuthenticationKeychainService
    let autofillService: AutofillService
    let killSwitchService: KillSwitchServiceProtocol
    let popoverOpeningService: PopoverOpeningService
    let sessionsContainer: SessionsContainerProtocol
    
    init(enclosingViewController: SFSafariExtensionViewController) {
        let localLogger = LocalLogger()
        self.appAPIClient = try! AppAPIClient()
        self.nonAuthenticatedUKIBasedWebService = LegacyWebServiceImpl(logger: localLogger[.network])
        remoteLogger = KibanaLogger(webService: nonAuthenticatedUKIBasedWebService,
                                    outputLevel: .fatal,
                                    origin: .safari)
        rootLogger = [
            localLogger,
            remoteLogger
        ]
        
        self.sessionsContainer = try! SessionsContainer(baseURL: ApplicationGroup.fiberSessionsURL,
                                                        cryptoEngineProvider: SessionCryptoEngineProvider(logger: rootLogger),
                                                        sessionStoreProvider: SessionStoreProvider())
        
        self.spiegelSettingsManager = SettingsManager(logger: rootLogger)
        self.communicationService = MainApplicationCommunicationService(logger: rootLogger[.localCommunication])
        self.sessionSharing = MainApplicationSessionSharing(communicationService: communicationService)
        self.crashReporterService = CrashReporterService(target: .safari)
        self.activityReporter = UserTrackingAppActivityReporter(logger: rootLogger[.userTrackingLogs],
                                                                component: .mainApp,
                                                                appAPIClient: appAPIClient,
                                                                platform: .safari)
        
        self.regionInformationService = try! RegionInformationService()
        self.categorizer = try! Categorizer()
        self.domainParser = try! DomainParser.defaultConfiguration()
        linkedDomainService = LinkedDomainService()
        self.personalDataURLDecoder = PersonalDataURLDecoder(domainParser: domainParser, linkedDomainService: linkedDomainService)
        self.passwordEvaluator = try! PasswordEvaluator()
        self.safariExtensionService = SafariExtensionService(enclosingViewController: enclosingViewController)

        self.keychainService = AuthenticationKeychainService(cryptoEngine: CryptoCenter(from: CryptoRawConfig.keyBasedDefault.parametersHeader)!, keychainSettingsDataProvider: spiegelSettingsManager, accessGroup: ApplicationGroup.keychainAccessGroup)

        let autofillServicesContainer = AutofillAppServicesContainer(communicationService: communicationService,
                                                                     passwordEvaluator: passwordEvaluator,
                                                                     domainParser: domainParser,
                                                                     regionInformationService: regionInformationService,
                                                                     personalDataURLDecoder: personalDataURLDecoder,
                                                                     logger: rootLogger[.autofill],
                                                                     appSettings: globalSettings,
                                                                     nonAuthenticatedWebService: LegacyWebServiceImpl(logger: rootLogger[.autofill]))

        self.autofillService = AutofillService(services: autofillServicesContainer)
        killSwitchService = KillSwitchService(apiClient: appAPIClient, logger: rootLogger)
        popoverOpeningService = PopoverOpeningService()
    }
}

extension SafariExtensionAppServices {
    func logout() {
        autofillService.disconnect()
    }
}
