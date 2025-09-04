import CorePersonalData
import CoreTeamAuditLogs
import DashlaneAPI

extension TeamAuditLogsServiceProtocol {

  func logCreate(_ collection: PrivateCollection) {
    logCreate([collection])
  }

  public func logCreate(_ collections: [PrivateCollection]) {
    for collection in collections {
      guard !collection.isSaved else {
        return
      }
      try? report(
        collection.generateReportableInfo(with: .create)
      )
    }
  }

  public func logRename(_ collection: PrivateCollection, oldCollectionName: String) {
    guard collection.isSaved else {
      return
    }
    try? report(
      collection.generateReportableInfo(with: .update(oldCollectionName: oldCollectionName))
    )
  }

  func logDelete(_ collection: PrivateCollection) {
    try? report(
      collection.generateReportableInfo(with: .delete)
    )
  }

  public func logImport(_ collections: [PrivateCollection]) {
    for collection in collections {
      try? report(
        collection.generateReportableInfo(
          with: .importCollection(credentialCount: collection.items.count))
      )
    }
  }

  public func logAddCredentialToCollection(_ collection: PrivateCollection, domainURL: String) {
    try? report(
      collection.generateReportableInfo(with: .addCredential(domainURL: domainURL))
    )
  }

  public func logDeleteCredentialToCollection(_ collection: PrivateCollection, domainURL: String) {
    try? report(
      collection.generateReportableInfo(with: .deleteCredential(domainURL: domainURL))
    )
  }

  func logUpdate(
    originalCollections: [VaultCollection], collections: [VaultCollection], for item: VaultItem
  ) {
    collections.difference(from: originalCollections).removals.forEach { removal in
      guard case .remove(_, let collection, _) = removal,
        let privateCollection = collection.privateCollection, let credential = item as? Credential
      else { return }
      logDeleteCredentialToCollection(
        privateCollection, domainURL: credential.url?.domain?.name ?? "")
    }

    collections.difference(from: originalCollections).insertions.forEach { insertion in
      guard case .insert(_, let collection, _) = insertion,
        let privateCollection = collection.privateCollection, let credential = item as? Credential
      else { return }
      logAddCredentialToCollection(privateCollection, domainURL: credential.url?.domain?.name ?? "")
    }
  }
}
