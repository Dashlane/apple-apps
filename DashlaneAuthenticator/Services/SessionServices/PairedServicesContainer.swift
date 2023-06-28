import Foundation
import CoreSession
import CoreSync
import DashlaneAppKit
import SwiftTreats
import CoreNetworking
import Logger
import CoreUserTracking
import Combine
import CorePersonalData
import AuthenticatorKit
import DashTypes
import IconLibrary
import VaultKit
import CoreSharing
import CoreFeature
import CoreActivityLogs
import CorePremium
import CoreSettings

struct PairedServicesContainer: DependenciesContainer {
    let session: Session
    let authenticationMode: AuthenticationMode
    let appServices: AppServices
    let database: ApplicationDatabase
    let pairedDatabaseService: PairedDatabaseService
    let syncService: SyncServiceProtocol
    let sharingService: SharedVaultHandling
    let authenticatorService: SessionAuthenticatorService
    let domainIconLibrary: DomainIconLibraryProtocol
    let activityLogsService: ActivityLogsService
    let premiumStatus: PremiumStatus
    let enabledFeatures: Set<ControlledFeature>
    let settings: LocalSettingsStore

    var databaseService: AuthenticatorDatabaseServiceProtocol { pairedDatabaseService }
    var sessionCredentialsProvider: SessionCredentialsProvider { pairedDatabaseService }

        init(session: Session,
         authenticationMode: AuthenticationMode,
         appServices: AppServices) async throws {

        self.session = session
        self.authenticationMode = authenticationMode
        self.appServices = appServices

        let ukiBasedWebService = LegacyWebServiceImpl(
            platform: .authenticator,
            logger: appServices.rootLogger[.network]
        )
        ukiBasedWebService.configureAuthentication(
            usingLogin: session.login.email,
            uki: session.configuration.keys.serverAuthentication.uki.rawValue
        )
        let userAPIClient = appServices.appAPIClient.makeUserClient(
            sessionConfiguration: session.configuration
        )

        self.authenticatorService = SessionAuthenticatorService(
            apiClient: userAPIClient,
            notificationService: appServices.notificationService
        )

        let featureService = await FeatureService(
            session: session,
            apiClient: userAPIClient.features,
            logger: appServices.rootLogger[.features]
        )
        self.enabledFeatures = featureService.enabledFeatures()

        domainIconLibrary = DomainIconLibrary(
            webService: appServices.nonAuthenticatedUKIBasedWebService,
            session: session,
            logger: appServices.rootLogger[.iconLibrary]
        )
        let databaseDriver = try SQLiteDriver(session: session, target: .current)
        settings = try appServices.spiegelSettingsManager.fetchOrCreateSettings(
            for: session.login,
            cryptoEngine: session.cryptoEngine
        )
        premiumStatus = try settings.keyed(by: UserEncryptedSettingsKey.self).premiumStatus().unwrapped

        let sharingKeysStore = await SharingKeysStore(
            session: session,
            logger: appServices.rootLogger[.sync]
        )

        self.activityLogsService = ActivityLogsService(
            spaces: premiumStatus.spaces ?? [],
            featureService: featureService,
            apiClient: userAPIClient.teams.storeActivityLogs,
            cryptoEngine: session.localCryptoEngine,
            logger: appServices.rootLogger[.activityLogs]
        )

        self.sharingService = try await SharingService(
            session: session,
            apiClient: userAPIClient.sharingUserdevice,
            codeDecoder: appServices.regionInformationService,
            personalDataURLDecoder: appServices.personalDataURLDecoder,
            databaseDriver: databaseDriver,
            sharingKeysStore: sharingKeysStore,
            activityLogsService: activityLogsService,
            logger: appServices.rootLogger[.sharing],
            activityReporter: appServices.activityReporter,
            autoRevokeUsersWithInvalidProposeSignature: false,
            buildTarget: .current
        )

        self.syncService = try await SyncService(
            apiClient: userAPIClient,
            activityReporter: appServices.activityReporter,
            sharingKeysStore: sharingKeysStore,
            databaseDriver: databaseDriver,
            sharingHandler: sharingService,
            session: session,
            syncLogger: appServices.rootLogger[.sync],
            target: .current
        )

        self.database = ApplicationDBStack(
            driver: databaseDriver,
            historyUserInfo: .init(
                session: session
            ),
            codeDecoder: appServices.regionInformationService,
            personalDataURLDecoder: appServices.personalDataURLDecoder,
            logger: appServices.rootLogger[.personalData]
        )

        appServices.crashReporterService.associate(to: session.login)

        pairedDatabaseService = PairedDatabaseService(
            login: session.login.email,
            appDatabase: database,
            databaseService: AuthenticatorDatabaseService(
                logger: appServices.rootLogger[.localCommunication]
            ),
            sharingService: sharingService,
            activityLogsService: activityLogsService
        )
    }
}
