import Combine
import CorePersonalData
import CoreSession
import DashTypes
import Foundation
import Logger

extension SQLiteDriver {
  public init(session: Session, target: BuildTarget) throws {
    let databaseURL = try session.directory
      .storeURL(for: .galactica, in: target)
      .appendingPathComponent("galactica.db")

    try self.init(
      url: databaseURL,
      cryptoEngine: session.localCryptoEngine,
      identifier: SQLiteClientIdentifier(target))
    try migrateTimestampIfNeeded(in: session, target: target)
  }

  private func migrateTimestampIfNeeded(in session: Session, target: BuildTarget) throws {
    let lastSyncTimestampURL = try session.lastSyncTimestampURL
    let oldStore = session.store(for: SyncService.SyncStoreKey.self)
    let newStore = BasicKeyedStore<SyncService.SyncStoreKey>(
      persistenceEngine: lastSyncTimestampURL)

    if oldStore.exists(for: .lastSyncTimestamp) && !newStore.exists(for: .lastSyncTimestamp) {
      let timestamp = oldStore.retrieve()
      try newStore.store(timestamp)
    }
  }
}

extension SQLiteClientIdentifier {
  init(_ target: BuildTarget) {
    switch target {
    case .app:
      self = .mainApp
    case .tachyon:
      self = .autofillExtension
    }
  }
}
