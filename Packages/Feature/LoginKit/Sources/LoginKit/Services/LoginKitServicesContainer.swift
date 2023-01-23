import Foundation
import DashTypes
import CoreSession
import CoreUserTracking
import CoreNetworking
import CoreKeychain
import CoreSettings
import Logger

public struct LoginKitServicesContainer: DependenciesContainer {
    let loginUsageLogService: LoginUsageLogServiceProtocol
    let activityReporter: ActivityReporterProtocol
    let keychainService: AuthenticationKeychainServiceProtocol
    let sessionCleaner: SessionCleaner
    let installerLogService: InstallerLogServiceProtocol
    let nonAuthenticatedUKIBasedWebService: LegacyWebService
    let sessionCryptoEngineProvider: SessionCryptoEngineProvider
    let sessionContainer: SessionsContainerProtocol
    let rootLogger: Logger
    let logger: LoginInstallerLogger
    let settingsManager: LocalSettingsFactory
    public let remoteLoginInfoProvider: RemoteLoginDelegate
    let appAPIClient: AppAPIClient
    let nitroWebService: NitroAPIClient
    
    public init(loginUsageLogService: LoginUsageLogServiceProtocol,
                activityReporter: ActivityReporterProtocol,
                sessionCleaner: SessionCleaner,
                logger: LoginInstallerLogger,
                settingsManager: LocalSettingsFactory,
                keychainService: AuthenticationKeychainServiceProtocol,
                installerLogService: InstallerLogServiceProtocol,
                nonAuthenticatedUKIBasedWebService: LegacyWebService,
                appAPIClient: AppAPIClient,
                sessionCryptoEngineProvider: SessionCryptoEngineProvider,
                sessionContainer: SessionsContainerProtocol,
                rootLogger: Logger,
                nitroWebService: NitroAPIClient) {
        self.loginUsageLogService = loginUsageLogService
        self.logger = logger
        self.settingsManager = settingsManager
        self.activityReporter = activityReporter
        self.keychainService = keychainService
        self.sessionCleaner = sessionCleaner
        self.installerLogService = installerLogService
        self.nonAuthenticatedUKIBasedWebService = nonAuthenticatedUKIBasedWebService
        self.appAPIClient = appAPIClient
        self.sessionCryptoEngineProvider = sessionCryptoEngineProvider
        self.sessionContainer = sessionContainer
        self.rootLogger = rootLogger
        self.remoteLoginInfoProvider = .init(logger: rootLogger[.session], cryptoProvider: sessionCryptoEngineProvider, appAPIClient: appAPIClient)
        self.nitroWebService = nitroWebService
    }
}
