import UIKit
import Combine
import Foundation
import DashTypes
import DomainParser
import CoreSession
import CorePersonalData
import CoreCategorizer
import CorePremium
import CoreSettings
import CoreNetworking
import CoreFeature
import SwiftTreats
import Logger
import DashlaneAppKit
import DashlaneAPI
import IconLibrary
import CoreSync
import CoreUserTracking
import VaultKit
import AutofillKit
import CoreActivityLogs

class SessionServicesContainer: DependenciesContainer {
    
    let session: Session
    let database: ApplicationDatabase
    let syncService: SyncService
    let teamSpacesService: TeamSpacesService
    let settings: LocalSettingsStore
    let userSettings: UserSettings
    let domainIconLibrary: DomainIconLibrary
    let appServices: AppServicesContainer
    let autofillService: AutofillService
    let featureService: FeatureService
    let authenticatedABTestingService: AuthenticatedABTestingService
    let activityReporter: ActivityReporterProtocol
    let premiumStatus: PremiumStatus?
    let activityLogsService: ActivityLogsServiceProtocol
    let userDeviceAPIClient: UserDeviceAPIClient
    
    private init(session: Session,
                 appServices: AppServicesContainer,
                 activityReporter: UserTrackingSessionActivityReporter,
                 database: ApplicationDatabase,
                 syncService: SyncService,
                 featureService: FeatureService,
                 authenticatedABTestingService: AuthenticatedABTestingService) throws {
        AppServicesContainer.crashReporterService.associate(to: session.login)
        appServices.remoteLogger.configureReportedDeviceId(session.configuration.keys.serverAuthentication.deviceId)
        self.session = session
        self.featureService = featureService
        self.syncService = syncService
        self.database = database
        self.appServices = appServices

        self.authenticatedABTestingService = authenticatedABTestingService
        appServices.settingsManager.cryptoEngine = session.localCryptoEngine
        self.activityReporter = activityReporter
        self.settings =  try appServices.settingsManager.fetchOrCreateSettings(for: session.login, cryptoEngine: session.cryptoEngine)
        self.userSettings = settings.keyed(by: UserSettingsKey.self)

        let cacheDirectory = try session.directory.storeURL(for: .icons, in: .current)
        domainIconLibrary =  DomainIconLibrary(cacheDirectory: cacheDirectory ,
                                               cryptoEngine: session.localCryptoEngine,
                                               webservice: appServices.nonAuthenticatedUKIBasedWebService,
                                               logger: appServices.rootLogger.sublogger(for: AppLoggerIdentifier.iconLibrary))
        premiumStatus = settings.keyed(by: UserEncryptedSettingsKey.self).premiumStatus()
        teamSpacesService = TeamSpacesService(status: premiumStatus)
        autofillService = AutofillService(channel: .fromTachyon,
                                          credentialsPublisher: database.itemsPublisher(for: Credential.self))
        self.userDeviceAPIClient = appServices.appAPIClient.makeUserClient(sessionConfiguration: session.configuration)
        self.activityLogsService = ActivityLogsService(spaces: premiumStatus?.spaces ?? [],
                                                 featureService: featureService,
                                                 apiClient: userDeviceAPIClient.teams.storeActivityLogs,
                                                 cryptoEngine: session.localCryptoEngine,
                                                 logger: appServices.rootLogger[.activityLogs])
    }
    
    
        static var shared: SessionServicesContainer?
    static var sessionServicesSubscription: AnyCancellable?
    
    public static func load(for session: Session, appServices: AppServicesContainer) async throws -> SessionServicesContainer {
        let userDeviceAPIClient = appServices.appAPIClient.makeUserClient(sessionConfiguration: session.configuration)
        let userAPIClient = appServices.appAPIClient.makeUserClient(sessionConfiguration: session.configuration)
        
                
        let featureService = await FeatureService(session: session,
                                                  apiClient: userDeviceAPIClient.features,
                                                  logger: appServices.rootLogger[.features])
        
        let activityReporter = UserTrackingSessionActivityReporter(appReporter: appServices.activityReporter, login: session.login, analyticsIdentifiers: session.configuration.keys.analyticsIds)
        
        let databaseDriver = try SQLiteDriver(session: session, target: .current)
        
        let fakeSharingHandler = TachyonSharingHandler() 
        let sharingKeysStore = await SharingKeysStore(session: session, logger: appServices.rootLogger[.sync])
        
        let syncService = try await SyncService(apiClient: userAPIClient,
                                                activityReporter: activityReporter,
                                                sharingKeysStore: sharingKeysStore,
                                                databaseDriver: databaseDriver,
                                                sharingHandler: fakeSharingHandler,
                                                session: session, syncLogger: appServices.rootLogger[.sync],
                                                target: .current)
        let applicationDatabase = await ApplicationDBStack(driver: databaseDriver,
                                                           historyUserInfo: .init(session: session),
                                                           codeDecoder: appServices.regionInformationService,
                                                           personalDataURLDecoder: appServices.personalDataURLDecoder,
                                                           logger: appServices.rootLogger[.personalData])

        let anonymousUserId = try applicationDatabase.fetch(with: Settings.id, type: Settings.self)?.anonymousUserId
        assert(anonymousUserId != nil)
        
        let settings =  try appServices.settingsManager.fetchOrCreateSettings(for: session.login, cryptoEngine: session.cryptoEngine)
        
                let abTestingService = AuthenticatedABTestingService(logger: appServices.rootLogger[.abTesting],
                                                             userEmail: session.login.email,
                                                             authenticatedAPIClient: userAPIClient,
                                                             isFirstLogin: false,
                                                             testsToEvaluate: AuthenticatedABTestingService.testsToEvaluate,
                                                             cache: settings.keyed(by: UserSettingsKey.self))
        abTestingService.setupAuthenticatedTesting(fetchNewTests: false)

        let container = try SessionServicesContainer(
            session: session,
            appServices: appServices,
            activityReporter: activityReporter,
            database: applicationDatabase,
            syncService: syncService,
            featureService: featureService,
            authenticatedABTestingService: abTestingService
        )

        await container.updateGlobalSessionEnvironment()

        shared = container
        return container
    }

    @MainActor
                            private func updateGlobalSessionEnvironment() {
        let activeEnvironment = GlobalEnvironmentValues.pushNewEnvironment()
        activeEnvironment.report = ReportAction(reporter: activityReporter)
        activeEnvironment.enabledAtLoginFeatures = featureService.enabledFeatures()
    }
}

private extension UserEncryptedSettings {
    func premiumStatus() -> PremiumStatus? {
        guard let data: Data = self[.premiumStatusData] else {
            return nil
        }
        
        return try? PremiumStatusService.decoder.decode(PremiumStatus.self, from: data)
    }
}

private class TachyonSharingHandler: SharingSyncHandler {
    func sync(using sharingInfo: CoreSync.SharingSummaryInfo?) async { }
}
