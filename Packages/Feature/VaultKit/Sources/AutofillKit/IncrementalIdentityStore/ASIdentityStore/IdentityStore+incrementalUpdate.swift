import AuthenticationServices
import CoreTypes
import Foundation

struct IncrementalStoreUpdate<Identity: Codable & Hashable> {
  var saved: SnapshotDictionary<Identity> = [:]
  var deleted: SnapshotDictionary<Identity> = [:]

  init(previousSnapshots: SnapshotDictionary<Identity>, newSnapshots: SnapshotDictionary<Identity>)
  {
    for (id, rank) in newSnapshots {
      if let oldValue = previousSnapshots[id] {
        if oldValue != rank {
          saved[id] = rank
        }
      } else {
        saved[id] = rank
      }
    }

    for (id, rank) in previousSnapshots where newSnapshots[id] == nil {
      deleted[id] = rank
    }
  }
}

extension IdentityStore {
  func incrementalUpdate(with update: IncrementalStoreUpdate<SnapshotSummary.CredentialIdentity>)
    async throws
  {
    if update.deleted.count > 0 {
      try await self.removeCredentialIdentities(update.deleted.makeIdentities())
    }

    if update.saved.count > 0 {
      try await self.saveCredentialIdentities(update.saved.makeIdentities())
    }
  }

  func incrementalUpdate(with update: IncrementalStoreUpdate<SnapshotSummary.PasskeyIdentity>)
    async throws
  {
    if update.deleted.count > 0 {
      try await self.removeCredentialIdentities(
        update.deleted.makeIdentities().map { $0 as ASCredentialIdentity })
    }

    if update.saved.count > 0 {
      try await self.saveCredentialIdentities(
        update.saved.makeIdentities().map { $0 as ASCredentialIdentity })
    }
  }
}
