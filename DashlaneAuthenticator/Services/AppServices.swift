import Foundation
import Combine
import DashTypes
import CoreNetworking
import CoreSync
import CoreSession
import CoreSettings
import DashlaneAppKit
import DashlaneCrypto
import Logger
import DomainParser
import CoreCategorizer
import CoreUserTracking
import SwiftTreats
import CoreKeychain
import IconLibrary
import LoginKit
import CorePersonalData
import VaultKit

public class AppServices: DependenciesContainer {
    let applicationState: ApplicationStateService
    let notificationService: NotificationService
    let appAPIClient: AppAPIClient
    let nonAuthenticatedUKIBasedWebService: LegacyWebService
    let ipcService: PasswordAppCommunicator
    let spiegelSettingsManager: SettingsManager
    let keychainService: AuthenticationKeychainService
    let rootLogger: Logger
    let remoteLogger: KibanaLogger
    let regionInformationService = try! RegionInformationService()
    let domainParser: DomainParserProtocol = try! DomainParser.defaultConfiguration()
    let linkedDomainService = LinkedDomainService()
    let categorizer: Categorizer = try! Categorizer()
    let activityReporter: ActivityReporterProtocol
    let crashReporterService: CrashReporterService
    let authenticatorAPIClient: AuthenticatorAPIClient
    let sessionsContainer: SessionsContainerProtocol
    let ratingService: RatingService

    init() {
        self.crashReporterService = CrashReporterService(target: .authenticator)
        let localLogger = LocalLogger()

        self.appAPIClient = try! AppAPIClient(platform: .authenticator)
        self.nonAuthenticatedUKIBasedWebService = LegacyWebServiceImpl(platform: .authenticator, logger: localLogger[.network])

        remoteLogger = KibanaLogger(webService: nonAuthenticatedUKIBasedWebService,
                                    outputLevel: .fatal,
                                    origin: .authenticator)
        self.rootLogger = [
            localLogger,
            remoteLogger
        ]
        activityReporter = UserTrackingAppActivityReporter(logger: rootLogger[.userTrackingLogs],
                                                           component: .mainApp,
                                                           installationId: UserTrackingAppActivityReporter.authenticatorAnalyticsInstallationId,
                                                           localStorageURL: ApplicationGroup.authenticatorLogsLocalStoreURL,
                                                           appAPIClient: appAPIClient,
                                                           platform: .authenticatorIos)

        sessionsContainer =  try! SessionsContainer(baseURL: ApplicationGroup.fiberSessionsURL,
                                                    cryptoEngineProvider: SessionCryptoEngineProvider(logger: rootLogger),
                                                    sessionStoreProvider: SessionStoreProvider())

        self.authenticatorAPIClient = AuthenticatorAPIClient(apiClient: appAPIClient)
        self.notificationService = NotificationService(apiClient: authenticatorAPIClient, sessionsContainer: sessionsContainer, activityReporter: activityReporter)

        spiegelSettingsManager = SettingsManager(logger: rootLogger[.localSettings])
        keychainService = AuthenticationKeychainService(cryptoEngine: CryptoCenter(from: CryptoRawConfig.keyBasedDefault.parametersHeader)!, keychainSettingsDataProvider: spiegelSettingsManager, accessGroup: ApplicationGroup.keychainAccessGroup)
        self.applicationState = ApplicationStateService(sessionsContainer: sessionsContainer, keychainService: keychainService, logger: rootLogger[.localCommunication], settingsManager: spiegelSettingsManager)
        ipcService = PasswordAppCommunicator(logger: rootLogger[.localCommunication], appState: applicationState)
        ratingService = RatingService()
    }
}

extension AppServices {
    var personalDataURLDecoder: PersonalDataURLDecoderProtocol {
        PersonalDataURLDecoder(domainParser: domainParser, linkedDomainService: linkedDomainService)
    }
}
