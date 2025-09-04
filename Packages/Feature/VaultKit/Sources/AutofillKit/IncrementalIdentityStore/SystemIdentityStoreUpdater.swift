import AuthenticationServices
import CorePersonalData
import CoreTypes
import Foundation

actor SystemIdentityStoreUpdater {
  enum IdentityStoreError: Error {
    case cannotPerformIncrementalUpdate
  }

  let identityStore: IdentityStore
  let snapshotPersistor: SnapshotPersistor
  private var currentSummary: SnapshotSummary?

  init(identityStore: IdentityStore, snapshotPersistor: SnapshotPersistor) {
    self.identityStore = identityStore
    self.snapshotPersistor = snapshotPersistor
  }

  private func retrieveSummary() -> SnapshotSummary {
    if let currentSummary {
      return currentSummary
    } else {
      let snapshot = snapshotPersistor.read()
      currentSummary = snapshot
      return snapshot
    }
  }
}

extension SystemIdentityStoreUpdater {
  struct UpdateRequest {
    let credentials: any Collection<Credential>
    let passkeys: any Collection<Passkey>
  }

  func update(with request: UpdateRequest) async throws {
    let state = await identityStore.state()

    guard state.isEnabled else {
      snapshotPersistor.remove()
      return
    }

    let currentSnapshots = self.retrieveSummary()
    let newSnapshotSummary = SnapshotSummary(
      credentials: request.credentials.makeSnapshots(),
      passkeys: request.passkeys.makeSnapshots()
    )

    if state.supportsIncrementalUpdates, !currentSnapshots.isEmpty, !newSnapshotSummary.isEmpty {
      let credentialUpdate = IncrementalStoreUpdate(
        previousSnapshots: currentSnapshots.credentials,
        newSnapshots: newSnapshotSummary.credentials)
      try await identityStore.incrementalUpdate(with: credentialUpdate)

      let passKeyUpdate = IncrementalStoreUpdate(
        previousSnapshots: currentSnapshots.passkeys, newSnapshots: newSnapshotSummary.passkeys)
      if passKeyUpdate.deleted.count > 0 {
        try await identityStore.fullUpdate(with: newSnapshotSummary)
      } else {
        try await identityStore.incrementalUpdate(with: passKeyUpdate)
      }
    } else {
      try await identityStore.fullUpdate(with: newSnapshotSummary)
    }

    snapshotPersistor.save(newSnapshotSummary)
    currentSummary = newSnapshotSummary
  }
}

extension SystemIdentityStoreUpdater {
  struct IndividualUpdateRequest<Item> {
    let new: Item
    let old: Item?
  }

  func update(with request: IndividualUpdateRequest<Credential>) async throws {
    let state = await identityStore.state()
    guard state.isEnabled else {
      return
    }

    guard state.supportsIncrementalUpdates else {
      throw IdentityStoreError.cannotPerformIncrementalUpdate
    }

    let previousSnapshots = request.old.map { [$0].makeSnapshots() }
    let newSnapshots = [request.new].makeSnapshots()

    let update = IncrementalStoreUpdate(
      previousSnapshots: previousSnapshots ?? [:], newSnapshots: newSnapshots)
    try await identityStore.incrementalUpdate(with: update)

    for deleted in update.deleted {
      currentSummary?.credentials.removeValue(forKey: deleted.key)
    }
    for saved in update.saved {
      currentSummary?.credentials[saved.key] = saved.value
    }

    if let currentSummary {
      snapshotPersistor.save(currentSummary)
    }
  }

  func update(with request: IndividualUpdateRequest<Passkey>) async throws {
    let state = await identityStore.state()
    guard state.isEnabled else {
      return
    }

    guard state.supportsIncrementalUpdates else {
      throw IdentityStoreError.cannotPerformIncrementalUpdate
    }

    let previousSnapshots = request.old.map { [$0].makeSnapshots() }

    let update = IncrementalStoreUpdate(
      previousSnapshots: previousSnapshots ?? [:], newSnapshots: [request.new].makeSnapshots())
    try await identityStore.incrementalUpdate(with: update)

    for deleted in update.deleted {
      currentSummary?.passkeys.removeValue(forKey: deleted.key)
    }
    for saved in update.saved {
      currentSummary?.passkeys[saved.key] = saved.value
    }

    if let currentSummary {
      snapshotPersistor.save(currentSummary)
    }
  }
}

extension SystemIdentityStoreUpdater {
  func clear() async throws {
    try await self.update(with: .init(credentials: [], passkeys: []))
  }
}
