import Foundation
import DomainParser
import CoreCategorizer
import DashTypes
import CoreNetworking
import CoreSettings
import CorePasswords
import CoreSession
import CoreFeature
import Logger
import DashlaneAppKit
import DashlaneCrypto
import LoginKit
import CoreKeychain
import CoreUserTracking


@MainActor
class AppServicesContainer {
    let settingsManager: SettingsManager
    let appSettings = AppSettings()
    let nonAuthenticatedUKIBasedWebService: LegacyWebService
    let appAPIClient: AppAPIClient
    let appExtensionCommunication = AppExtensionCommunicationCenter.init(channel: .fromApp)
    let rootLogger: Logger
    let remoteLogger: KibanaLogger
    private let memoryPressureLogger: MemoryPressureLogger
    let regionInformationService = try! RegionInformationService()
    let loginUsageLogService: LoginUsageLogService
    let linkedDomainService = LinkedDomainService()
    let passwordEvaluator = try! PasswordEvaluator()
    let activityReporter: UserTrackingAppActivityReporter
    lazy var domainParser = try! DomainParser(quickParsing: true)
    lazy var categorizer = try! Categorizer()
    var installerLogService: InstallerLogService
    let unauthenticatedABTestingService: UnauthenticatedABTestingService
    let sessionsContainer: SessionsContainerProtocol
    static let crashReporterService =  CrashReporterService(target: .tachyon)
    public static let sharedInstance = AppServicesContainer(appLaunchTimeStamp: Date().timeIntervalSince1970)
    let keychainService: AuthenticationKeychainService
    let nitroWebService: NitroAPIClient
    init(appLaunchTimeStamp: TimeInterval) {
        loginUsageLogService = LoginUsageLogService(appLaunchTimeStamp: appLaunchTimeStamp)
        loginUsageLogService.markAsLoadingSessionFromSavedLogin()
        _ = AppServicesContainer.crashReporterService
        let localLogger = LocalLogger()
        appAPIClient = try! AppAPIClient()
        nonAuthenticatedUKIBasedWebService = LegacyWebServiceImpl(logger: localLogger[.network])
        remoteLogger = KibanaLogger(webService: nonAuthenticatedUKIBasedWebService,
                                    outputLevel: .fatal,
                                    origin: .tachyon)
        self.rootLogger = [
            localLogger,
            remoteLogger
        ]
        settingsManager = SettingsManager(logger: rootLogger[.localSettings])
        
        sessionsContainer = try! SessionsContainer(baseURL: ApplicationGroup.fiberSessionsURL,
                                                   cryptoEngineProvider: SessionCryptoEngineProvider(logger: rootLogger),
                                                   sessionStoreProvider: SessionStoreProvider())
        
        memoryPressureLogger = MemoryPressureLogger(webService: nonAuthenticatedUKIBasedWebService, origin: .tachyon)
        self.activityReporter = UserTrackingAppActivityReporter(logger: rootLogger[.userTrackingLogs],
                                                                component: .osAutofill,
                                                                appAPIClient: appAPIClient,
                                                                platform: .ios)
        self.installerLogService = InstallerLogService(appSettings: appSettings, webService: nonAuthenticatedUKIBasedWebService)
        self.nitroWebService = NitroAPIClient(engine: try! NitroAPIClientEngineImp(info: .init()))
        unauthenticatedABTestingService = UnauthenticatedABTestingService(logger: rootLogger[.abTesting],
                                                                          abTestInstallerlogger: installerLogService,
                                                                          apiClient: appAPIClient,
                                                                          testsToEvaluate: UnauthenticatedABTestingService.testsToEvaluate,
                                                                          cache: appSettings)
        keychainService = AuthenticationKeychainService(cryptoEngine: CryptoCenter(from: CryptoRawConfig.keyBasedDefault.parametersHeader)!, keychainSettingsDataProvider: settingsManager, accessGroup: ApplicationGroup.keychainAccessGroup)

        updateGlobalAppEnvironment()
    }

                        private func updateGlobalAppEnvironment() {
        let activeEnvironment = GlobalEnvironmentValues.pushNewEnvironment()
        activeEnvironment.report = ReportAction(reporter: activityReporter)
    }
}

extension AppServicesContainer {
    var personalDataURLDecoder: PersonalDataURLDecoder {
        PersonalDataURLDecoder(domainParser: domainParser, linkedDomainService: linkedDomainService)
    }
}
