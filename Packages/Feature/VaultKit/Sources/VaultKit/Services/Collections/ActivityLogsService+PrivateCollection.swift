import CoreActivityLogs
import CorePersonalData

extension ActivityLogsServiceProtocol {

  func logCreate(_ collection: PrivateCollection) {
    logCreate([collection])
  }

  public func logCreate(_ collections: [PrivateCollection]) {
    guard isEnabled else { return }
    for collection in collections {
      guard let info = collection.reportableInfo(), !collection.isSaved else {
        return
      }
      try? report(.creation, for: info)
    }
  }

  public func logRename(_ collection: PrivateCollection, oldCollectionName: String) {
    guard isEnabled, let info = collection.reportableInfo(oldCollectionName: oldCollectionName),
      collection.isSaved
    else {
      return
    }
    try? report(.update, for: info)
  }

  func logDelete(_ collection: PrivateCollection) {
    guard isEnabled, let info = collection.reportableInfo() else {
      return
    }
    try? report(.deletion, for: info)
  }

  public func logImport(_ collections: [PrivateCollection]) {
    for collection in collections {
      guard isEnabled, let info = collection.reportableInfo(credentialCount: collection.items.count)
      else {
        return
      }

      try? report(.importCollection, for: info)
    }
  }

  public func logAddCredentialToCollection(_ collection: PrivateCollection, domainURL: String) {
    guard isEnabled, let info = collection.reportableInfo(domainURL: domainURL) else {
      return
    }
    try? report(.addCredential, for: info)
  }

  public func logDeleteCredentialToCollection(_ collection: PrivateCollection, domainURL: String) {
    guard isEnabled, let info = collection.reportableInfo(domainURL: domainURL) else {
      return
    }
    try? report(.deleteCredential, for: info)
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
