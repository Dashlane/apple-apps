import Combine
import CorePersonalData
import CorePremium
import DashTypes
import DashlaneAPI
import Foundation

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
    logger: Logger
  ) {

    let handleTeamRevoke = TeamSpaceRevokeHandler(
      database: database,
      sharingService: sharingService,
      apiClient: apiClient)

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
      .combineLatest(vaultItemsStore.$credentials, vaultItemsStore.$emails)
      .debounce(for: .seconds(5), scheduler: DispatchQueue.main)
      .sink { configuration, credentials, emails in
        do {
          try vaultItemDatabase.enforceSpaceIfNeeded(on: credentials, for: configuration)
          try vaultItemDatabase.enforceSpaceIfNeeded(on: emails, for: configuration)
        } catch {
          logger.fatal("Failed to enforce space", error: error)
        }
      }.store(in: &subscriptions)
  }
}
