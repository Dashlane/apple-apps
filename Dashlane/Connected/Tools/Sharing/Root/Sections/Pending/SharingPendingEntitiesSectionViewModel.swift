import Combine
import CoreLocalization
import CorePersonalData
import CorePremium
import CoreSession
import CoreSharing
import CoreTypes
import DesignSystem
import Foundation
import VaultKit

@MainActor
class SharingPendingEntitiesSectionViewModel: ObservableObject, SessionServicesInjecting {
  let vaultItemIconViewModelFactory: VaultItemIconViewModel.Factory

  @Published
  var pendingItemGroups: [PendingDecodedItemGroup] = []

  @Published
  var pendingCollections: [PendingCollection] = []

  @Published
  var isSpaceSelectionRequired: Bool = false
  private var pendingSpaceSelectionContinuation: CheckedContinuation<UserSpace?, Never>? {
    didSet {
      isSpaceSelectionRequired = pendingSpaceSelectionContinuation != nil
    }
  }

  var availableSpaces: [UserSpace] {
    return userSpacesService.configuration.availableSpaces.filter {
      $0 != .both
    }
  }

  private let sharingService: SharingServiceProtocol
  let userSpacesService: UserSpacesService

  public init(
    sharingService: SharingServiceProtocol,
    userSpacesService: UserSpacesService,
    vaultItemIconViewModelFactory: VaultItemIconViewModel.Factory
  ) {
    self.sharingService = sharingService
    self.userSpacesService = userSpacesService
    self.vaultItemIconViewModelFactory = vaultItemIconViewModelFactory

    sharingService.pendingItemGroupsPublisher()
      .combineLatest(sharingService.pendingItemsPublisher()) {
        pendingGroups, pendingItems -> [PendingDecodedItemGroup] in
        return pendingGroups.compactMap { pendingGroup -> PendingDecodedItemGroup? in
          guard let firstId = pendingGroup.itemIds.first, let item = pendingItems[firstId] else {
            return nil
          }

          return PendingDecodedItemGroup(
            itemGroupInfo: pendingGroup.itemGroupInfo, item: item, referrer: pendingGroup.referrer)
        }
      }
      .receive(on: DispatchQueue.main)
      .assign(to: &$pendingItemGroups)

    sharingService.pendingCollectionsPublisher()
      .receive(on: DispatchQueue.main)
      .assign(to: &$pendingCollections)
  }

  func accept(_ group: PendingDecodedItemGroup) async throws {
    guard let team = userSpacesService.configuration.currentTeam else {
      try await sharingService.accept(group, in: .personal)
      return
    }

    if let forcedSpace = userSpacesService.configuration.forcedSpace(for: group.item) {
      try await sharingService.accept(group, in: forcedSpace)
    } else if group.item.spaceId == team.personalDataId {
      try await sharingService.accept(group)
    } else {
      let space = await withCheckedContinuation { continuation in
        self.pendingSpaceSelectionContinuation = continuation
      }
      guard let space = space else {
        return
      }

      try await sharingService.accept(group, in: space)
    }
  }

  func select(_ userSpace: UserSpace?) {
    pendingSpaceSelectionContinuation?.resume(returning: userSpace)
    pendingSpaceSelectionContinuation = nil
  }

  func refuse(_ group: PendingDecodedItemGroup) async throws {
    try await sharingService.refuse(group.itemGroupInfo, loggedItem: group.item)
  }

  func accept(_ collection: PendingCollection, toast: ToastAction) async throws {
    try await sharingService.accept(collection.collectionInfo)
    toast(CoreL10n.sharingAcceptedMessage(collection.collectionInfo.name))
  }

  func refuse(_ collection: PendingCollection) async throws {
    try await sharingService.refuse(collection.collectionInfo)
  }
}

public struct PendingDecodedItemGroup: Identifiable {
  public let itemGroupInfo: ItemGroupInfo
  public let item: VaultItem
  public let referrer: String?

  public var id: Identifier {
    return itemGroupInfo.id
  }
}

extension SharingServiceProtocol {
  func accept(_ group: PendingDecodedItemGroup, in userSpace: UserSpace? = nil) async throws {
    if let personalDataId = userSpace?.personalDataId {
      update(spaceId: personalDataId, toPendingItem: group.item)
    }

    try await accept(group.itemGroupInfo, loggedItem: group.item)
  }
}
