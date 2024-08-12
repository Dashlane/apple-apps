import Combine
import CorePremium
import CoreSharing
import CoreUserTracking
import DashTypes
import DocumentServices
import Foundation
import SwiftUI
import UIComponents

final class VaultItemEditionService<Item: VaultItem & Equatable>: ObservableObject {

  @Published var item: Item
  var originalItem: Item

  @Binding var mode: DetailMode

  var itemDidChange: Bool {
    item != originalItem
  }

  private let vaultItemDatabase: VaultItemDatabaseProtocol
  private let sharingService: SharedVaultHandling
  private let userSpacesService: UserSpacesService
  private let documentStorageService: DocumentStorageService
  private let activityReporter: ActivityReporterProtocol

  private var itemChangeSubcription: AnyCancellable?

  init(
    item: Item,
    mode: Binding<DetailMode>,
    vaultItemDatabase: VaultItemDatabaseProtocol,
    sharingService: SharedVaultHandling,
    userSpacesService: UserSpacesService,
    documentStorageService: DocumentStorageService,
    activityReporter: ActivityReporterProtocol
  ) {
    self.item = item
    self.originalItem = item
    self._mode = mode
    self.vaultItemDatabase = vaultItemDatabase
    self.sharingService = sharingService
    self.userSpacesService = userSpacesService
    self.documentStorageService = documentStorageService
    self.activityReporter = activityReporter

    setupUpdateOnDatabaseChange()
  }

  private func setupUpdateOnDatabaseChange() {
    itemChangeSubcription =
      vaultItemDatabase
      .itemPublisher(for: item)
      .receive(on: DispatchQueue.main)
      .sink { [weak self] item in
        if self?.mode == .viewing {
          self?.item = item
          self?.originalItem = item
        }
      }
  }

  func update(using mode: Binding<DetailMode>) {
    _mode = mode
  }

  func cancel() {
    item = originalItem
  }

  func delete() async throws {
    try await documentStorageService
      .documentDeleteService
      .deleteAllAttachments(of: item)
    await MainActor.run {
      self.vaultItemDatabase.dispatchDelete(self.item)
    }
  }

  func updateItemSpaceIfForced() {
    guard let space = userSpacesService.configuration.forcedSpace(for: item) else {
      return
    }

    item.spaceId = space.personalDataId
  }

  func itemDeleteBehavior() async throws -> ItemDeleteBehaviour {
    try await sharingService.deleteBehaviour(for: item)
  }

  func sharingPermission() -> SharingPermission? {
    sharingService.permission(for: item)
  }

  func hasLimitedRights() -> Bool {
    sharingPermission() == .limited
  }

  func configureDefaultSpace() {
    item.spaceId = userSpacesService.configuration.defaultSpace(for: item).personalDataId
  }

  func updateLastLocalUseDate() {
    if !mode.isEditing {
      vaultItemDatabase.updateLastUseDate(of: [item], origin: [.default])
    }
  }
}

extension VaultItemEditionService {
  func prepareForSaving() throws {
    updateItemSpaceIfForced()
  }

  func save(with selectedUserSpace: UserSpace, itemCollectionsCount: Int) throws {
    guard itemDidChange else {
      return
    }
    let now = Date()
    if mode.isAdding {
      item.creationDatetime = now
    }
    item.userModificationDatetime = now

    if let forcedSpace = userSpacesService.configuration.forcedSpace(for: item) {
      item.spaceId = forcedSpace.personalDataId
    }

    let savedItem = try vaultItemDatabase.save(item)
    activityReporter.vaultEdition.logUpdate(
      with: .init(
        mode: mode,
        savedItem: savedItem,
        item: item,
        originalItem: originalItem,
        itemCollectionsCount: itemCollectionsCount,
        selectedUserSpace: selectedUserSpace
      )
    )
    originalItem = savedItem
    item = savedItem
  }
}
