import Foundation
import DashTypes
import CoreSession
import CoreUserTracking
import CoreNetworking
import CoreKeychain
import CoreSettings
import Logger
import CorePasswords

public struct LoginKitServicesContainer: DependenciesContainer {
    public let loginMetricsReporter: LoginMetricsReporterProtocol
    public let activityReporter: ActivityReporterProtocol
    public let keychainService: AuthenticationKeychainServiceProtocol
    public let sessionCleaner: SessionCleaner
    public let nonAuthenticatedUKIBasedWebService: LegacyWebService
    public let sessionCryptoEngineProvider: SessionCryptoEngineProvider
    public let sessionContainer: SessionsContainerProtocol
    public let rootLogger: Logger
    public let settingsManager: LocalSettingsFactory
    public let remoteLoginInfoProvider: RemoteLoginDelegate
    public let appAPIClient: AppAPIClient
    public let nitroWebService: NitroAPIClient
    public let passwordEvaluvator: PasswordEvaluatorProtocol
    
    public init(loginMetricsReporter: LoginMetricsReporterProtocol,
                activityReporter: ActivityReporterProtocol,
                sessionCleaner: SessionCleaner,
                settingsManager: LocalSettingsFactory,
                keychainService: AuthenticationKeychainServiceProtocol,
                nonAuthenticatedUKIBasedWebService: LegacyWebService,
                appAPIClient: AppAPIClient,
                sessionCryptoEngineProvider: SessionCryptoEngineProvider,
                sessionContainer: SessionsContainerProtocol,
                rootLogger: Logger,
                nitroWebService: NitroAPIClient,
                passwordEvaluvator: PasswordEvaluatorProtocol) {
        self.loginMetricsReporter = loginMetricsReporter
        self.settingsManager = settingsManager
        self.activityReporter = activityReporter
        self.keychainService = keychainService
        self.sessionCleaner = sessionCleaner
        self.nonAuthenticatedUKIBasedWebService = nonAuthenticatedUKIBasedWebService
        self.appAPIClient = appAPIClient
        self.sessionCryptoEngineProvider = sessionCryptoEngineProvider
        self.sessionContainer = sessionContainer
        self.rootLogger = rootLogger
        self.remoteLoginInfoProvider = .init(logger: rootLogger[.session], cryptoProvider: sessionCryptoEngineProvider, appAPIClient: appAPIClient)
        self.nitroWebService = nitroWebService
        self.passwordEvaluvator = passwordEvaluvator
    }
}
