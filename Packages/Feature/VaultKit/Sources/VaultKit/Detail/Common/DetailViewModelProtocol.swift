import Combine
import CorePersonalData
import CorePremium
import CoreSharing
import DashTypes
import Foundation
import UIComponents

public protocol DetailViewModelProtocol: ObservableObject {
  associatedtype Item: VaultItem, Equatable

  var service: DetailService<Item> { get }
}

extension DetailViewModelProtocol {

  public var item: Item {
    get {
      service.vaultItemEditionService.item
    }
    set {
      service.vaultItemEditionService.item = newValue
    }
  }

  public var canShowLock: Bool {
    item is SecureItem && service.canLock
  }

  public var originalItem: Item {
    service.vaultItemEditionService.originalItem
  }

  public var allVaultCollections: [VaultCollection] {
    get {
      service.vaultCollectionEditionService.allVaultCollections
    }
    set {
      service.vaultCollectionEditionService.allVaultCollections = newValue
    }
  }

  public var itemCollections: [VaultCollection] {
    get {
      service.vaultCollectionEditionService.itemCollections
    }
    set {
      service.vaultCollectionEditionService.itemCollections = newValue
    }
  }

  public var unusedCollections: [VaultCollection] {
    get {
      service.vaultCollectionEditionService.unusedCollections
    }
    set {
      service.vaultCollectionEditionService.unusedCollections = newValue
    }
  }

  public var mode: DetailMode {
    get {
      service.mode
    }
    set {
      service.mode = newValue
    }
  }

  public var eventPublisher: PassthroughSubject<DetailServiceEvent, Never> {
    service.eventPublisher
  }

  public var sharingPermission: SharingPermission? {
    service.sharingPermission()
  }

  public var hasLimitedRights: Bool {
    service.hasLimitedRights()
  }

  public var isUserSpaceForced: Bool {
    service.isUserSpaceForced
  }

  public var selectedUserSpace: UserSpace {
    get {
      service.selectedUserSpace
    }
    set {
      service.selectedUserSpace = newValue
    }
  }

  public var availableUserSpaces: [UserSpace] {
    service.availableUserSpaces
  }

  public var advertiseUserActivity: Bool {
    service.advertiseUserActivity
  }

  public var alert: DetailViewAlert? {
    get {
      service.alert
    }
    set {
      service.alert = newValue
    }
  }

  public var isFrozen: Bool {
    service.isFrozen
  }

  public var isLoading: Bool {
    service.isLoading
  }

  public var isSaving: Bool {
    service.isSaving
  }

  public func sendUsageLog(fieldType: DetailFieldType) {
    service.sendViewUsageLog(for: fieldType)
  }

  public func copy(_ value: String, fieldType: DetailFieldType) {
    service.copy(value, fieldType: fieldType)
  }

  public func showInVault() {
    service.showInVault()
  }

  public func addItemToNewCollection(named: String) {
    service.vaultCollectionEditionService.addItem(toNewCollectionNamed: named)
  }

  public func addItem(to existingCollection: VaultCollection) {
    service.vaultCollectionEditionService.addItem(to: existingCollection)
  }

  public func removeItem(from collection: VaultCollection) {
    service.vaultCollectionEditionService.removeItem(from: collection)
  }

  public func cancel() {
    service.cancel()
  }

  public func confirmCancel() {
    service.confirmCancel()
  }

  public func itemDeleteBehavior() async throws -> ItemDeleteBehaviour {
    try await service.itemDeleteBehavior()
  }

  public func delete() async {
    await service.delete()
  }

  public var canSave: Bool {
    service.canSave
  }

  public func prepareForSaving() throws {
    try service.prepareForSaving()
  }

  @MainActor
  public func save() async {
    await service.save()
  }

  public func saveIfViewing() {
    service.saveIfViewing()
  }

  public func reportDetailViewAppearance() {
    service.reportDetailViewAppearance()
  }

  public var iconViewModel: VaultItemIconViewModel {
    service.iconViewModel
  }
}
