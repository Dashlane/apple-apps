import CorePersonalData
import CorePremium
import UIComponents
import UserTrackingFoundation

extension ActivityReporterProtocol {
  var vaultEdition: VaultEditionReporter { .init(activityReporter: self) }
}

struct VaultEditionReporter {

  struct VaultItemLogInfo {
    let mode: DetailMode
    let savedItem: VaultItem
    let item: VaultItem
    let originalItem: VaultItem
    let itemCollectionsCount: Int
    let selectedUserSpace: UserSpace
  }

  private let activityReporter: ActivityReporterProtocol

  init(activityReporter: ActivityReporterProtocol) {
    self.activityReporter = activityReporter
  }

  func logUpdate(with info: VaultItemLogInfo) {
    let action: Definition.Action = info.mode.isAdding ? .add : .edit
    var fieldsEdited: [Definition.Field] = []

    if let savedItem = info.savedItem as? Credential {
      fieldsEdited = logUpdate(savedItem, info: info)
    }
    let itemCollectionsCount = info.itemCollectionsCount
    let item = info.item
    let fields = fieldsEdited
    let selectedUserSpace = info.selectedUserSpace
    activityReporter.report(
      UserEvent.UpdateVaultItem(
        action: action,
        collectionCount: itemCollectionsCount,
        fieldsEdited: fields.isEmpty ? nil : fields,
        itemId: item.userTrackingLogID,
        itemType: item.vaultItemType,
        space: selectedUserSpace.logItemSpace)
    )
  }

  private func logUpdate(_ credential: Credential, info: VaultItemLogInfo) -> [Definition.Field] {
    var fieldsEdited: [Definition.Field] = []

    if let originalItem = info.originalItem as? Credential,
      credential.linkedServices != originalItem.linkedServices
    {
      fieldsEdited.append(.associatedWebsitesList)
      let fieldList = fieldsEdited
      let item = info.item
      let selectedUserSpace = info.selectedUserSpace
      activityReporter.report(
        AnonymousEvent.UpdateCredential(
          action: Definition.Action.edit,
          associatedWebsitesAddedList: credential.linkedServices.associatedDomains
            .filterDomainsNotExisting(in: originalItem).ids(),
          associatedWebsitesRemovedList: originalItem.linkedServices.associatedDomains
            .filterDomainsNotExisting(in: credential).ids(),
          domain: item.hashedDomainForLogs(),
          fieldList: fieldList,
          space: selectedUserSpace.logItemSpace)
      )
    }

    return fieldsEdited
  }

  func logUpdate(
    originalCollections: [VaultCollection], collections: [VaultCollection], for item: VaultItem
  ) {
    collections.difference(from: originalCollections).removals.forEach { removal in
      guard case .remove(_, let collection, _) = removal else { return }
      log(item, removedFrom: collection)
    }

    collections.difference(from: originalCollections).insertions.forEach { insertion in
      guard case .insert(_, let collection, _) = insertion else { return }
      log(item, addedIn: collection)
    }
  }

  private func log(_ item: VaultItem, addedIn collection: VaultCollection) {
    if collection.itemIds.count == 1, collection.contains(item) {
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

  private func log(_ item: VaultItem, removedFrom collection: VaultCollection) {
    activityReporter.report(
      UserEvent.UpdateCollection(
        action: .deleteCredential,
        collectionId: collection.id.rawValue,
        isShared: collection.isShared,
        itemCount: 1)
    )
  }
}

extension [LinkedServices.AssociatedDomain] {
  fileprivate func filterDomainsNotExisting(in credential: Credential) -> [Definition.Domain] {
    self
      .filter { !credential.linkedServices.associatedDomains.contains($0) }
      .map { $0.domain.hashedDomainForLogs() }
  }
}

extension [Definition.Domain] {
  fileprivate func ids() -> [String] {
    compactMap(\.id)
  }
}
