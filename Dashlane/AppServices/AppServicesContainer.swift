import Foundation
import CoreSession
import DomainParser
import CoreNetworking
import DashlaneCrypto
import CoreKeychain
import CorePasswords
import DashTypes
import CoreSettings
import CoreCategorizer
import CoreFeature
import Logger
import DashlaneAppKit
import AuthenticatorKit
import LoginKit
import NotificationKit
import CoreUserTracking

final class AppServicesContainer: DependenciesContainer {
    let nonAuthenticatedUKIBasedWebService: LegacyWebServiceImpl
    let appAPIClient: AppAPIClient
    let nitroWebService: NitroAPIClient
    let sessionCryptoEngineProvider: SessionCryptoEngineProvider
    let sessionContainer: SessionsContainerProtocol
    let rootLogger: Logger
    let remoteLogger: KibanaLogger
    private let memoryPressureLogger: MemoryPressureLogger
    let domainParser: DomainParser
    let linkedDomainService: LinkedDomainService
    let categorizer: Categorizer
    let regionInformationService: RegionInformationService
    let userCountryProvider: UserCountryProvider
    let globalSettings = AppSettings()
    let keychainService: AuthenticationKeychainService
    weak var sessionLifeCycleHandler: SessionLifeCycleHandler?
    let passwordEvaluator: PasswordEvaluator
    let crashReporter: CrashReporterService
    let installerLogService: InstallerLogService
    let notificationService: NotificationService
    let deepLinkingService: DeepLinkingService
    let loginUsageLogService: LoginUsageLogService
    let networkReachability: NetworkReachability
    let unauthenticatedABTestingService: UnauthenticatedABTestingService
    let spotlightIndexer: SpotlightIndexer
    let spiegelSettingsManager: SettingsManager
    let activityReporter: UserTrackingAppActivityReporter
    let versionValidityService: VersionValidityService
    #if targetEnvironment(macCatalyst)
    let appKitBridge: AppKitBridgeProtocol
    let safariExtensionService: SafariExtensionService
    #endif
    let authenticatorDatabaseService: AuthenticatorDatabaseService
    let brazeService: BrazeServiceProtocol

    @MainActor
        init(sessionLifeCycleHandler: SessionLifeCycleHandler,
         crashReporter: CrashReporterService,
         appLaunchTimeStamp: TimeInterval) throws {
        self.crashReporter = crashReporter
        globalSettings.configure()

        let localLogger = LocalLogger()
        self.appAPIClient = try AppAPIClient()
        self.nitroWebService = NitroAPIClient(engine: try NitroAPIClientEngineImp(info: .init()))
        networkReachability = NetworkReachability()
        nonAuthenticatedUKIBasedWebService = LegacyWebServiceImpl(logger: localLogger[.network])

        remoteLogger = KibanaLogger(webService: nonAuthenticatedUKIBasedWebService,
                                    outputLevel: .fatal,
                                    origin: .mainApplication)
        rootLogger = [
            localLogger,
            remoteLogger
        ]
        authenticatorDatabaseService = AuthenticatorDatabaseService(logger: rootLogger)
        spiegelSettingsManager = SettingsManager(logger: rootLogger)

        domainParser = try DomainParser.defaultConfiguration()
        linkedDomainService = LinkedDomainService()
        categorizer = try Categorizer()
        regionInformationService = try RegionInformationService()
        userCountryProvider = UserCountryProvider(regionInformationService: regionInformationService)
        userCountryProvider.load(ukiBasedWebService: nonAuthenticatedUKIBasedWebService)
        keychainService = AuthenticationKeychainService(cryptoEngine: CryptoCenter(from: CryptoRawConfig.keyBasedDefault.parametersHeader)!, keychainSettingsDataProvider: spiegelSettingsManager, accessGroup: ApplicationGroup.keychainAccessGroup)

        sessionCryptoEngineProvider = SessionCryptoEngineProvider(logger: rootLogger)
        sessionContainer = try SessionsContainer(baseURL: ApplicationGroup.fiberSessionsURL,
                                                 cryptoEngineProvider: sessionCryptoEngineProvider,
                                                 sessionStoreProvider: SessionStoreProvider())

        memoryPressureLogger = MemoryPressureLogger(webService: nonAuthenticatedUKIBasedWebService, origin: .mainApplication)

        installerLogService = InstallerLogService(logger: rootLogger[.installerLogs],
                                                  appSettings: globalSettings,
                                                  networkReachability: networkReachability)

        activityReporter = UserTrackingAppActivityReporter(logger: rootLogger[.userTrackingLogs],
                                                           component: .mainApp,
                                                           appAPIClient: appAPIClient,
                                                           platform: .ios)
        passwordEvaluator = try PasswordEvaluator()
        self.brazeService = BrazeService(logger: rootLogger)
        notificationService = NotificationService(logger: rootLogger[.remoteNotifications])
        self.deepLinkingService = DeepLinkingService(sessionLifeCycleHandler: sessionLifeCycleHandler, notificationService: notificationService, brazeService: brazeService)
        self.sessionLifeCycleHandler = sessionLifeCycleHandler
        loginUsageLogService = LoginUsageLogService(appLaunchTimeStamp: appLaunchTimeStamp)

        spotlightIndexer = SpotlightIndexer(logger: rootLogger[.spotlight])
        unauthenticatedABTestingService = UnauthenticatedABTestingService(logger: rootLogger[.abTesting],
                                                                          abTestInstallerlogger: installerLogService.abTesting,
                                                                          apiClient: appAPIClient,
                                                                          testsToEvaluate: UnauthenticatedABTestingService.testsToEvaluate,
                                                                          cache: globalSettings)
        versionValidityService = VersionValidityService(apiClient: appAPIClient,
                                                        appSettings: globalSettings,
                                                        logoutHandler: sessionLifeCycleHandler,
                                                        logger: rootLogger[.versionValidity],
                                                        activityReporter: activityReporter)
        #if targetEnvironment(macCatalyst)
        appKitBridge = AppKitBundleLoader.load()
        safariExtensionService = SafariExtensionService(appKitBridge: appKitBridge, logger: rootLogger)
        #endif
        updateGlobalAppEnvironment()
    }

    @MainActor
                        private func updateGlobalAppEnvironment() {
        let activeEnvironment = GlobalEnvironmentValues.pushNewEnvironment()
        activeEnvironment.report = ReportAction(reporter: activityReporter)
    }
}

extension AppServicesContainer {
    var personalDataURLDecoder: DashlaneAppKit.PersonalDataURLDecoder {
        PersonalDataURLDecoder(domainParser: domainParser, linkedDomainService: linkedDomainService)
    }
}

extension LoginKitServicesContainer: AppServicesInjecting {

}
