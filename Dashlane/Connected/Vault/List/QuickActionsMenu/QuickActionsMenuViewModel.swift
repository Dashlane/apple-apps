import Combine
import CoreActivityLogs
import CorePersonalData
import CorePremium
import CoreSettings
import CoreSharing
import CoreUserTracking
import DashTypes
import Foundation
import SwiftTreats
import VaultKit

@MainActor
class QuickActionsMenuViewModel: SessionServicesInjecting, MockVaultConnectedInjecting,
  ObservableObject
{
  let item: VaultItem
  let copyResultPublisher = PassthroughSubject<ActionableVaultItemRowViewModel.CopyResult, Never>()
  let sharingService: SharedVaultHandling
  let vaultItemDatabase: VaultItemDatabaseProtocol
  let vaultCollectionEditionService: VaultCollectionAndItemEditionService
  let activityReporter: ActivityReporterProtocol
  let itemPasteboard: ItemPasteboardProtocol
  let origin: ActionableVaultItemRowViewModel.Origin
  let isSuggestedItem: Bool
  let shareFlowViewModelFactory: ShareFlowViewModel.Factory
  let sharingDeactivationReason: SharingDeactivationReason?
  let accessControl: AccessControlProtocol

  @Published
  var allVaultCollections: [VaultCollection]
  @Published
  var unusedCollections: [VaultCollection]
  @Published
  var itemCollections: [VaultCollection]

  private var subscriptions = Set<AnyCancellable>()

  init(
    item: VaultItem,
    sharingService: SharedVaultHandling,
    accessControl: AccessControlProtocol,
    vaultItemDatabase: VaultItemDatabaseProtocol,
    vaultCollectionDatabase: VaultCollectionDatabaseProtocol,
    vaultCollectionsStore: VaultCollectionsStore,
    userSpacesService: UserSpacesService,
    activityReporter: ActivityReporterProtocol,
    activityLogsService: ActivityLogsServiceProtocol,
    shareFlowViewModelFactory: ShareFlowViewModel.Factory,
    origin: ActionableVaultItemRowViewModel.Origin,
    pasteboardService: PasteboardServiceProtocol,
    isSuggestedItem: Bool
  ) {
    self.vaultItemDatabase = vaultItemDatabase
    self.sharingService = sharingService
    self.item = item
    self.shareFlowViewModelFactory = shareFlowViewModelFactory
    self.sharingDeactivationReason =
      userSpacesService.configuration.currentTeam?.teamInfo.sharingDisabled == true
      ? .b2bSharingDisabled : nil
    self.activityReporter = activityReporter
    self.origin = origin
    self.isSuggestedItem = isSuggestedItem
    self.itemPasteboard = ItemPasteboard(
      accessControl: accessControl, pasteboardService: pasteboardService)
    self.allVaultCollections = []
    self.itemCollections = []
    self.unusedCollections = []
    self.accessControl = accessControl
    self.vaultCollectionEditionService = .init(
      item: item,
      mode: .constant(.viewing),
      vaultCollectionDatabase: vaultCollectionDatabase,
      vaultCollectionsStore: vaultCollectionsStore,
      activityReporter: activityReporter,
      activityLogsService: activityLogsService
    )

    vaultCollectionsStore
      .$collections
      .receive(on: RunLoop.main)
      .sink { [weak self] allVaultCollections in
        guard let self = self else {
          return
        }
        self.allVaultCollections = allVaultCollections
        self.itemCollections = allVaultCollections.filter(bySpaceId: item.spaceId).filter(by: item)
        self.unusedCollections =
          allVaultCollections
          .filter(bySpaceId: item.spaceId)
          .difference(from: itemCollections)
          .compactMap {
            guard case .insert(_, let collection, _) = $0 else {
              return nil
            }
            return collection
          }
      }
      .store(in: &subscriptions)
  }
}

extension QuickActionsMenuViewModel {
  func deleteBehaviour() async throws -> ItemDeleteBehaviour {
    try await sharingService.deleteBehaviour(for: item.id)
  }

  func delete() {
    vaultItemDatabase.dispatchDelete(item)
    activityReporter.reportPageShown(.confirmItemDeletion)
  }

  func copy(fieldType: Definition.Field, valueToCopy: String) {
    guard sharingService.canCopyProperties(in: item) else {
      copyResultPublisher.send(.limitedRights)
      return
    }

    guard let securableItem = item as? SecureItem, securableItem.secured else {
      copy(value: valueToCopy, for: fieldType)
      return
    }
    accessControl.requestAccess { [weak self] success in
      guard let self, success else { return }
      self.copy(value: valueToCopy, for: fieldType)
    }

  }

  private func copy(value: String, for field: Definition.Field) {
    var lastUpdateOrigin: Set<LastUseUpdateOrigin> = [.default]
    if origin == .search {
      lastUpdateOrigin.insert(.search)
    }

    vaultItemDatabase.updateLastUseDate(of: [item], origin: lastUpdateOrigin)

    sendCopyUsageLog(fieldType: field)

    itemPasteboard
      .copy(item, valueToCopy: value)
      .map { $0 ? .success(fieldType: field) : .authenticationDenied }
      .sink(receiveValue: copyResultPublisher.send)
      .store(in: &subscriptions)
  }

}

extension QuickActionsMenuViewModel {
  func addItem(toNewCollectionNamed: String) throws {
    vaultCollectionEditionService.addItem(toNewCollectionNamed: toNewCollectionNamed)
    Task {
      try await vaultCollectionEditionService.save()
    }
  }

  func addItem(to collection: VaultCollection) throws {
    vaultCollectionEditionService.addItem(to: collection)
    Task {
      try await vaultCollectionEditionService.save()
    }
  }

  func removeItem(from collections: [VaultCollection]) throws {
    collections.forEach { collection in
      vaultCollectionEditionService.removeItem(from: collection)
    }
    Task {
      try await vaultCollectionEditionService.save()
    }
  }
}

extension QuickActionsMenuViewModel {
  func sendCopyUsageLog(fieldType: Definition.Field) {
    activityReporter.reportPageShown(.homeQuickActionsDropdown)
    let isProtected: Bool
    if let secureItem = item as? SecureItem {
      isProtected = secureItem.secured
    } else {
      isProtected = false
    }
    let item = item
    let highlight = origin.definitionHighlight(isSuggestedItem)
    activityReporter.report(
      UserEvent.CopyVaultItemField(
        field: fieldType,
        highlight: highlight,
        isProtected: isProtected,
        itemId: item.userTrackingLogID,
        itemType: item.vaultItemType
      )
    )
    activityReporter.report(
      AnonymousEvent.CopyVaultItemField(
        domain: item.hashedDomainForLogs(),
        field: fieldType,
        itemType: item.vaultItemType
      )
    )
  }

  private func log(itemAddedIn collection: VaultCollection, originalCollections: [VaultCollection])
  {
    guard !collection.itemIds.isEmpty else { return }

    if !originalCollections.contains(where: { $0.id == collection.id }) {
      activityReporter.report(
        UserEvent.UpdateCollection(
          action: .add,
          collectionId: collection.id.rawValue,
          isShared: collection.isShared,
          itemCount: 1)
      )
    }

    activityReporter.report(
      UserEvent.UpdateCollection(
        action: .addCredential,
        collectionId: collection.id.rawValue,
        isShared: collection.isShared,
        itemCount: 1)
    )
  }

  private func log(itemRemovedFrom collection: VaultCollection) {
    activityReporter.report(
      UserEvent.UpdateCollection(
        action: .deleteCredential,
        collectionId: collection.id.rawValue,
        isShared: collection.isShared,
        itemCount: 1)
    )
  }

  private func logUpdate(
    originalCollections: [VaultCollection],
    originalItemCollections: [VaultCollection],
    itemCollections: [VaultCollection]
  ) {
    itemCollections.difference(from: originalItemCollections).removals.forEach { removal in
      guard case .remove(_, let collection, _) = removal else { return }
      log(itemRemovedFrom: collection)
    }

    itemCollections.difference(from: originalItemCollections).insertions.forEach { insertion in
      guard case .insert(_, let collection, _) = insertion else { return }
      log(itemAddedIn: collection, originalCollections: originalCollections)
    }
  }

  func reportAppearance() {
    let vaultItemType = item.vaultItemType
    activityReporter.report(
      UserEvent.OpenVaultItemDropdown(dropdownType: .quickActions, itemType: vaultItemType))
  }
}

extension QuickActionsMenuViewModel {
  static func mock(item: VaultItem) -> QuickActionsMenuViewModel {
    QuickActionsMenuViewModel(
      item: item,
      sharingService: SharedVaultHandlerMock(),
      accessControl: FakeAccessControl(accept: true),
      vaultItemDatabase: MockVaultKitServicesContainer().vaultItemDatabase,
      vaultCollectionDatabase: MockVaultKitServicesContainer().vaultCollectionDatabase,
      vaultCollectionsStore: MockVaultConnectedContainer().vaultCollectionsStore,
      userSpacesService: .mock(),
      activityReporter: .mock,
      activityLogsService: .mock(),
      shareFlowViewModelFactory: .init { _, _, _ in .mock() },
      origin: .home,
      pasteboardService: .mock(),
      isSuggestedItem: true
    )
  }
}
