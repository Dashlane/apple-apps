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

struct PairedServicesContainer: DependenciesContainer, AuthenticatorServicesContainer {
    let session: Session
    let authenticationMode: AuthenticationMode
    let appServices: AppServices
    let database: ApplicationDatabase
    let pairedDatabaseService: PairedDatabaseService
    let syncService: SyncServiceProtocol
    let sharingService: SharedVaultHandling
    let authenticatorService: SessionAuthenticatorService
    let domainIconLibrary: DomainIconLibraryProtocol
    
    var databaseService: AuthenticatorDatabaseServiceProtocol { pairedDatabaseService }
    var sessionCredentialsProvider: SessionCredentialsProvider { pairedDatabaseService }
    
    init(session: Session,
         authenticationMode: AuthenticationMode,
         appServices: AppServices) async throws {

        self.session = session
        self.authenticationMode = authenticationMode
        self.appServices = appServices
        
        let ukiBasedWebService = LegacyWebServiceImpl(platform: .authenticator, logger: appServices.rootLogger[.network])
        ukiBasedWebService.configureAuthentication(usingLogin: session.login.email, uki: session.configuration.keys.serverAuthentication.uki.rawValue)
        let userAPIClient = appServices.appAPIClient.makeUserClient(sessionConfiguration: session.configuration)
        
        self.authenticatorService = SessionAuthenticatorService(apiClient: userAPIClient, notificationService: appServices.notificationService)
        
        let featureService = await FeatureService(session: session,
                                                  apiClient: userAPIClient.features,
                                                  logger: appServices.rootLogger[.features])
        domainIconLibrary = DomainIconLibrary(webService: appServices.nonAuthenticatedUKIBasedWebService, session: session, logger: appServices.rootLogger[.iconLibrary])
        let databaseDriver = try SQLiteDriver(session: session, target: .current)
        
        let sharingKeysStore = await SharingKeysStore(session: session, logger: appServices.rootLogger[.sync])
        self.sharingService = try await SharingService(session: session,
                                                       apiClient: userAPIClient.sharingUserdevice,
                                                       codeDecoder: appServices.regionInformationService,
                                                       personalDataURLDecoder: appServices.personalDataURLDecoder,
                                                       databaseDriver: databaseDriver,
                                                       sharingKeysStore: sharingKeysStore,
                                                       logger: appServices.rootLogger[.sharing],
                                                       activityReporter: appServices.activityReporter)

        self.syncService = try await SyncService(apiClient: userAPIClient,
                                                 activityReporter: appServices.activityReporter,
                                                 sharingKeysStore: sharingKeysStore,
                                                 databaseDriver: databaseDriver,
                                                 sharingHandler: sharingService,
                                                 session: session,
                                                 syncLogger: appServices.rootLogger[.sync],
                                                 target: .current)
        
        self.database = ApplicationDBStack(driver: databaseDriver,
                                           historyUserInfo: .init(session: session),
                                           codeDecoder: appServices.regionInformationService,
                                           personalDataURLDecoder: appServices.personalDataURLDecoder,
                                           logger: appServices.rootLogger[.personalData])
        
        appServices.crashReporterService.associate(to: session.login)
        
        pairedDatabaseService = PairedDatabaseService(login: session.login.email,
                                                      appDatabase: database,
                                                      databaseService: AuthenticatorDatabaseService(logger: appServices.rootLogger[.authenticator]),
                                                      sharingService: sharingService)
    }
}
