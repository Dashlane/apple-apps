import CoreFeature
import CoreLocalization
import CorePremium
import CoreSharing
import DashTypes
import Foundation
import SwiftUI
import VaultKit

@MainActor
class ShareFlowViewModel: ObservableObject, SessionServicesInjecting, MockVaultConnectedInjecting {
  enum ComposeStep: Hashable {
    case items
    case recipients
  }

  enum State: Hashable {
    case composing
    case sending
    case success
  }

  @Published
  var hasSucceed: Bool = false

  @Published
  var composeSteps: [ComposeStep]

  @Published
  var state: State = .composing

  @Published
  var errorMessage: String = "" {
    didSet {
      showError = !errorMessage.isEmpty
    }
  }

  @Published
  var showError: Bool = false

  var items: [VaultItem] = []
  var recipientsConfiguration: RecipientsConfiguration = .init()

  let itemsViewModelFactory: ShareItemsSelectionViewModel.Factory
  let recipientsViewModelFactory: ShareRecipientsSelectionViewModel.Factory
  let sharingService: SharingServiceProtocol
  let capabilityService: CapabilityServiceProtocol

  init(
    items: [VaultItem] = [],
    userGroupIds: Set<Identifier> = [],
    userEmails: Set<String> = [],
    sharingService: SharingServiceProtocol,
    capabilityService: CapabilityServiceProtocol,
    itemsViewModelFactory: ShareItemsSelectionViewModel.Factory,
    recipientsViewModelFactory: ShareRecipientsSelectionViewModel.Factory
  ) {
    self.items = items
    self.recipientsConfiguration = .init(userEmails: userEmails, groupIds: userGroupIds)

    self.sharingService = sharingService
    self.capabilityService = capabilityService
    self.itemsViewModelFactory = itemsViewModelFactory
    self.recipientsViewModelFactory = recipientsViewModelFactory

    if self.items.isEmpty {
      self.composeSteps = [.items]
    } else {
      self.composeSteps = [.recipients]
    }
  }

  func makeItemsViewModel() -> ShareItemsSelectionViewModel {
    itemsViewModelFactory.make { [weak self] items in
      guard let self else {
        return
      }

      self.items = items
      self.composeSteps.append(.recipients)
    }
  }

  func makeRecipientsViewModel() -> ShareRecipientsSelectionViewModel {
    let showTeamOnly = capabilityService.status(of: .internalSharingOnly).isAvailable
    return recipientsViewModelFactory.make(
      configuration: recipientsConfiguration, showTeamOnly: showTeamOnly
    ) { [weak self] configuration in
      guard let self else {
        return
      }

      self.recipientsConfiguration = configuration
      self.share()
    }
  }

  func share() {
    Task {
      state = .sending
      let limit = capabilityService.capabilities[.sharingLimit]?.info?.limit

      do {
        try await sharingService.share(
          items,
          recipients: Array(recipientsConfiguration.userEmails),
          userGroupIds: Array(recipientsConfiguration.groupIds),
          permission: recipientsConfiguration.permission,
          limitPerUser: limit)
        hasSucceed = true
      } catch SharingUpdaterError.sharingLimitReached {
        state = .composing
        errorMessage = L10n.Localizable.kwSharingPremiumLimit
      } catch let urlError as URLError where urlError.code == .notConnectedToInternet {
        state = .composing
        errorMessage = CoreLocalization.L10n.Core.kwNoInternet
      } catch {
        state = .composing
        errorMessage = L10n.Localizable.lockAlreadyAcquired
      }
    }

  }
}

extension ShareFlowViewModel {
  static func mock(
    items: [VaultItem] = [],
    userGroupIds: Set<Identifier> = [],
    userEmails: Set<String> = [],
    sharingService: SharingServiceProtocol = SharingServiceMock()
  ) -> ShareFlowViewModel {
    ShareFlowViewModel(
      items: items,
      userGroupIds: userGroupIds,
      userEmails: userEmails,
      sharingService: sharingService,
      capabilityService: .mock(),
      itemsViewModelFactory: .init { .mock(completion: $0) },
      recipientsViewModelFactory: .init { _, _, _, _ in .mock(sharingService: sharingService) })
  }
}
