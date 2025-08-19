import Combine
import CorePersonalData
import CorePremium
import CoreTypes
import DashlaneAPI
import Foundation
import LogFoundation

public class TeamRulesEnforcer {
  var subscriptions: [AnyCancellable] = []

  public init(
    statusProvider: PremiumStatusProvider,
    userSpacesService: UserSpacesService,
    database: ApplicationDatabase,
    sharingService: SharingServiceProtocol,
    vaultItemsStore: VaultItemsStore,
    vaultItemDatabase: VaultItemDatabaseProtocol,
    apiClient: UserDeviceAPIClient.Teams,
    cloudPasskeysService: UserSecureNitroEncryptionAPIClient.Passkeys,
    logger: Logger
  ) {

    let handleTeamRevoke = TeamSpaceRevokeHandler(
      database: database,
      sharingService: sharingService,
      apiClient: apiClient,
      cloudPasskeysService: cloudPasskeysService,
      logger: logger)

    statusProvider.statusPublisher
      .debounce(for: .seconds(2), scheduler: DispatchQueue.main)
      .sink { status in
        Task {
          do {
            try await handleTeamRevoke(for: status)
          } catch {
            logger.fatal("Failed to handle team revoke", error: error)
          }
        }

      }.store(in: &subscriptions)

    userSpacesService.$configuration
      .filter {
        $0.availableSpaces.count > 1
          && $0.currentTeam?.teamInfo.forcedDomainsEnabled == true
      }
      .combineLatest(
        vaultItemsStore.$credentials, vaultItemsStore.$emails, vaultItemsStore.$secrets
      )
      .debounce(for: .seconds(5), scheduler: DispatchQueue.main)
      .sink { configuration, credentials, emails, secrets in
        do {
          try vaultItemDatabase.enforceSpaceIfNeeded(on: credentials, for: configuration)
          try vaultItemDatabase.enforceSpaceIfNeeded(on: emails, for: configuration)
          try vaultItemDatabase.enforceSpaceIfNeeded(on: secrets, for: configuration)
        } catch {
          logger.fatal("Failed to enforce space", error: error)
        }
      }.store(in: &subscriptions)
  }
}
