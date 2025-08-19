import CoreCategorizer
import CoreFeature
import CorePersonalData
import CorePremium
import CoreSession
import CoreSettings
import CoreTeamAuditLogs
import CoreTypes
import DashlaneAPI
import LogFoundation
import UserTrackingFoundation

public struct VaultServicesSuit: DependenciesContainer {
  public let vaultItemDatabase: VaultItemDatabaseProtocol
  public let vaultItemsStore: VaultItemsStore

  public let vaultCollectionDatabase: VaultCollectionDatabaseProtocol
  public let vaultCollectionsStore: VaultCollectionsStore

  public let vaultItemsLimitService: VaultItemsLimitService
  public let prefilledCredentialsProvider: PrefilledCredentialsProviderProtocol
  public let defaultVaultItemsService: DefaultVaultItemsServiceProtocol

  let vaultItemsSpotlightService: VaultItemsSpotlightService

  public init(
    logger: Logger,
    login: Login,
    spotlightIndexer: SpotlightIndexer?,
    userSettings: UserSettings,
    categorizer: Categorizer,
    urlDecoder: PersonalDataURLDecoderProtocol,
    sharingHandling: SharedVaultHandling,
    sharingService: SharingServiceProtocol,
    database: ApplicationDatabase,
    userSpacesService: UserSpacesService,
    featureService: FeatureServiceProtocol,
    capabilityService: CapabilityServiceProtocol,
    teamAuditLogsService: TeamAuditLogsServiceProtocol,
    cloudPasskeyService: UserSecureNitroEncryptionAPIClient.Passkeys,
    activityReporter: ActivityReporterProtocol
  ) async {
    self.vaultItemDatabase = VaultItemDatabase(
      logger: logger,
      database: database,
      sharingService: sharingHandling,
      featureService: featureService,
      userSpacesService: userSpacesService,
      teamAuditLogsService: teamAuditLogsService,
      cloudPasskeyService: cloudPasskeyService
    )

    self.vaultItemsStore = await VaultItemsStoreImpl(
      vaultItemDatabase: vaultItemDatabase,
      userSpacesService: userSpacesService,
      featureService: featureService,
      capabilityService: capabilityService
    )

    self.vaultCollectionDatabase = VaultCollectionDatabase(
      logger: logger,
      database: database,
      sharingService: sharingService,
      userSpacesService: userSpacesService,
      activityReporter: activityReporter,
      teamAuditLogsService: teamAuditLogsService
    )

    self.vaultCollectionsStore = VaultCollectionsStoreImpl(
      logger: logger,
      vaultCollectionDatabase: vaultCollectionDatabase
    )

    self.vaultItemsLimitService = VaultItemsLimitService(
      capabilityService: capabilityService,
      credentialsPublisher: vaultItemsStore.$credentials
    )

    self.prefilledCredentialsProvider = PrefilledCredentialsProvider(
      login: login,
      urlDecoder: urlDecoder
    )

    self.vaultItemsSpotlightService = VaultItemsSpotlightService(
      vaultItemsStore: vaultItemsStore,
      userSettings: userSettings,
      spotlightIndexer: spotlightIndexer
    )

    self.defaultVaultItemsService = DefaultVaultItemsService(
      login: login,
      logger: logger,
      database: database,
      userSpacesService: userSpacesService,
      categorizer: categorizer
    )
  }

  public func unload(reason: SessionServicesUnloadReason) {
    vaultItemsSpotlightService.unload(reason: reason)
  }
}
