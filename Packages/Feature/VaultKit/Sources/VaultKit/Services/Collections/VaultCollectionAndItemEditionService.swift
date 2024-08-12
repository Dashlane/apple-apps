import Combine
import CoreActivityLogs
import CorePersonalData
import CoreUserTracking
import DashTypes
import Foundation
import SwiftUI
import UIComponents

public final class VaultCollectionAndItemEditionService: ObservableObject {

  private var item: VaultItem

  @Published var allVaultCollections: [VaultCollection] = []
  private var originalAllVaultCollections: [VaultCollection] = []

  @Published var itemCollections: [VaultCollection] = []
  private var originalItemCollections: [VaultCollection] = []

  @Published var unusedCollections: [VaultCollection] = []

  @Binding private var mode: DetailMode

  var isSaving: Bool = false

  private let vaultCollectionDatabase: VaultCollectionDatabaseProtocol
  private let vaultCollectionsStore: VaultCollectionsStore
  private let activityReporter: ActivityReporterProtocol
  private let activityLogsService: ActivityLogsServiceProtocol

  private var cancellables: Set<AnyCancellable> = []

  public init(
    item: VaultItem,
    mode: Binding<DetailMode>,
    vaultCollectionDatabase: VaultCollectionDatabaseProtocol,
    vaultCollectionsStore: VaultCollectionsStore,
    activityReporter: ActivityReporterProtocol,
    activityLogsService: ActivityLogsServiceProtocol
  ) {
    self.item = item
    self._mode = mode
    self.vaultCollectionDatabase = vaultCollectionDatabase
    self.vaultCollectionsStore = vaultCollectionsStore
    self.activityReporter = activityReporter
    self.activityLogsService = activityLogsService

    setup()
  }

  private func setup() {
    updateAllCollections(with: vaultCollectionsStore.collections)
    updateCollections(with: vaultCollectionsStore.collections.filter(by: item))
    updateUnusedCollections()

    setupUpdateOnDatabaseChanges()
  }

  private func setupUpdateOnDatabaseChanges() {
    vaultCollectionsStore
      .$collections
      .receive(on: DispatchQueue.main)
      .sink { [weak self] collections in
        if self?.mode == .viewing {
          self?.updateAllCollections(with: collections)
        }
      }
      .store(in: &cancellables)

    vaultCollectionsStore
      .collectionsPublisher(for: item)
      .receive(on: DispatchQueue.main)
      .sink { [weak self] collections in
        if self?.mode == .viewing {
          self?.updateCollections(with: collections)
        }
      }
      .store(in: &cancellables)
  }

  func collectionsDidChange() -> Bool {
    allVaultCollections != originalAllVaultCollections
  }

  func update<Item: VaultItem & Equatable>(
    using mode: Binding<DetailMode>,
    itemPublisher: AnyPublisher<Item, Never>
  ) {
    _mode = mode
    itemPublisher
      .sink { [weak self] item in
        guard let self, !self.isSaving else { return }
        self.item = item
        self.updateAllCollections(with: self.vaultCollectionsStore.collections)
        self.updateCollections(with: self.vaultCollectionsStore.collections.filter(by: item))
      }
      .store(in: &cancellables)
  }

  func cancel() {
    allVaultCollections = originalAllVaultCollections
    itemCollections = originalItemCollections
  }

  func updateCollectionsAfterSpaceChange() {
    removeItemFromAllCollections()
    updateUnusedCollections()
  }

  private func updateAllCollections(with collections: [VaultCollection]) {
    let sortedCollections = collections.filter(bySpaceId: item.spaceId).sortedByName()
    allVaultCollections = sortedCollections
    originalAllVaultCollections = sortedCollections
    updateUnusedCollections()
  }

  private func updateCollections(with collections: [VaultCollection]) {
    let sortedCollections = collections.filter(bySpaceId: item.spaceId).sortedByName()
    itemCollections = sortedCollections
    originalItemCollections = sortedCollections
    updateUnusedCollections()
  }

  func updateUnusedCollections() {
    let allCollectionsInSpace = allVaultCollections.filter(bySpaceId: item.spaceId)
    unusedCollections = allCollectionsInSpace.difference(from: itemCollections).compactMap {
      guard case .insert(_, let collection, _) = $0 else { return nil }
      return collection
    }
  }

  public func addItem(toNewCollectionNamed: String) {
    add(item, toNewCollectionNamed: toNewCollectionNamed)
  }

  public func addItem(to existingCollection: VaultCollection) {
    add(item, to: existingCollection)
  }

  private func add(
    _ item: VaultItem,
    toNewCollectionNamed: String
  ) {
    var newCollection = PrivateCollection(name: toNewCollectionNamed, spaceId: item.spaceId ?? "")
    newCollection.insert(item)

    let newVaultCollection = VaultCollection(collection: newCollection)
    allVaultCollections.append(newVaultCollection)
    itemCollections.append(newVaultCollection)

    allVaultCollections.sortByName()
    itemCollections.sortByName()
  }

  private func add(
    _ item: VaultItem,
    to collection: VaultCollection
  ) {
    guard collection.belongsToSpace(id: item.spaceId) else {
      assertionFailure("Item from one space can't be added to a collection from another space")
      return
    }

    let updatedCollection = {
      guard !collection.contains(item) else { return collection }

      var collectionCopy = collection
      collectionCopy.insert(item)

      return collectionCopy
    }()

    guard let index = allVaultCollections.firstIndex(where: { $0.id == updatedCollection.id })
    else {
      assertionFailure("Collection \(updatedCollection) does not exist")
      return
    }

    allVaultCollections[index] = updatedCollection
    itemCollections.append(updatedCollection)
    unusedCollections.removeAll(where: { $0.id == updatedCollection.id })

    itemCollections.sortByName()
  }

  public func removeItem(from collection: VaultCollection) {
    allVaultCollections.remove(item, from: collection)
    itemCollections.removeAll(where: { $0.id == collection.id })
    unusedCollections.append(collection)
    unusedCollections.sortByName()
  }

  private func removeItemFromAllCollections() {
    itemCollections.forEach { removeItem(from: $0) }
  }

  func updateCollectionsSpaceIfForced() {
    for index in 0..<allVaultCollections.count {
      guard allVaultCollections[index].contains(item),
        !allVaultCollections[index].belongsToSpace(id: item.spaceId)
      else { continue }
      if allVaultCollections[index].itemIds.count == 1 {
        allVaultCollections[index].moveToSpace(withId: item.spaceId)
      } else {
        allVaultCollections[index].remove(item)
      }
    }
  }

  public func save() async throws {
    guard collectionsDidChange() else { return }
    let savedCollections = try await allVaultCollections.asyncMap {
      try await vaultCollectionDatabase.save($0)
    }
    activityReporter.vaultEdition.logUpdate(
      originalCollections: originalItemCollections,
      collections: itemCollections,
      for: item
    )
    activityLogsService.logUpdate(
      originalCollections: originalItemCollections,
      collections: itemCollections,
      for: item
    )
    originalAllVaultCollections = savedCollections
    allVaultCollections = savedCollections
    let itemCollections = savedCollections.filter(by: item).filter(bySpaceId: item.spaceId)
    self.itemCollections = itemCollections
    self.originalItemCollections = itemCollections
  }
}
