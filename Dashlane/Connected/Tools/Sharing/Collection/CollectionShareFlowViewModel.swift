import CoreLocalization
import CorePersonalData
import CorePremium
import CoreSharing
import DashTypes
import Foundation
import SwiftUI
import VaultKit

@MainActor
class CollectionShareFlowViewModel: ObservableObject, SessionServicesInjecting,
  MockVaultConnectedInjecting
{

  enum State: Hashable {
    case sending
  }

  @Published
  var state: [State] = []

  @Published
  var hasSucceed: Bool = false

  @Published
  var errorMessage: String = "" {
    didSet {
      showError = !errorMessage.isEmpty
    }
  }

  @Published
  var showError: Bool = false

  var collection: VaultCollection
  var recipientsConfiguration: RecipientsConfiguration

  let recipientsViewModelFactory: ShareRecipientsSelectionViewModel.Factory

  let sharingService: SharingServiceProtocol
  let userSpacesService: UserSpacesService
  let vaultCollectionDatabase: VaultCollectionDatabaseProtocol

  init(
    collection: VaultCollection,
    userGroupIds: Set<Identifier> = [],
    userEmails: Set<String> = [],
    sharingService: SharingServiceProtocol,
    vaultCollectionDatabase: VaultCollectionDatabaseProtocol,
    userSpacesService: UserSpacesService,
    recipientsViewModelFactory: ShareRecipientsSelectionViewModel.Factory
  ) {
    self.collection = collection
    self.recipientsConfiguration = .init(
      userEmails: userEmails, groupIds: userGroupIds, permission: .admin, sharingType: .collection)

    self.sharingService = sharingService
    self.vaultCollectionDatabase = vaultCollectionDatabase
    self.userSpacesService = userSpacesService
    self.recipientsViewModelFactory = recipientsViewModelFactory
  }

  func makeRecipientsViewModel() -> ShareRecipientsSelectionViewModel {
    return recipientsViewModelFactory.make(
      configuration: recipientsConfiguration, showPermissionLevelSelector: false, showTeamOnly: true
    ) { [weak self] configuration in
      guard let self else {
        return
      }

      self.recipientsConfiguration = configuration
      self.share()
    }
  }

  func share() {
    state.append(.sending)

    Task {
      do {
        let teamId = userSpacesService.configuration.currentTeam?.teamId
        try await vaultCollectionDatabase.share(
          [collection],
          teamId: teamId,
          recipients: Array(recipientsConfiguration.userEmails),
          userGroupIds: Array(recipientsConfiguration.groupIds),
          permission: recipientsConfiguration.permission
        )
        hasSucceed = true
      } catch SharingUpdaterError.sharingLimitReached {
        update(newErrorMessage: L10n.Localizable.kwSharingPremiumLimit)
      } catch let urlError as URLError where urlError.code == .notConnectedToInternet {
        update(newErrorMessage: CoreLocalization.L10n.Core.kwNoInternet)
      } catch {
        update(newErrorMessage: L10n.Localizable.lockAlreadyAcquired)
      }
    }
  }

  @MainActor
  private func update(newErrorMessage: String) {
    errorMessage = newErrorMessage
    state = []
  }
}

extension CollectionShareFlowViewModel {
  static func mock(
    items: [VaultItem] = [],
    userGroupIds: Set<Identifier> = [],
    userEmails: Set<String> = [],
    sharingService: SharingServiceProtocol = SharingServiceMock()
  ) -> CollectionShareFlowViewModel {
    CollectionShareFlowViewModel(
      collection: VaultCollection(collection: PrivateCollection()),
      userGroupIds: userGroupIds,
      userEmails: userEmails,
      sharingService: sharingService,
      vaultCollectionDatabase: MockVaultConnectedContainer().vaultCollectionDatabase,
      userSpacesService: .mock(),
      recipientsViewModelFactory: .init { _, _, _, _ in .mock(sharingService: sharingService) }
    )
  }
}
