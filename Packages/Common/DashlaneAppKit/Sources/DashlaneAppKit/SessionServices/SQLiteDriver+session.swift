import Foundation
import CoreSession
import CorePersonalData
import Logger
import Combine
import DashTypes

extension SQLiteDriver {
    public init(session: Session, target: BuildTarget) throws {
        let databaseURL = try session.directory
            .storeURL(for: .galactica, in: target)
            .appendingPathComponent("galactica.db")
    
        try self.init(url: databaseURL,
                  cryptoEngine: session.localCryptoEngine,
                  identifier: SQLiteClientIdentifier(target))
        try importLegacyCoreDataIfExist(in: session, target: target)
        try migrateTimestampIfNeeded(in: session, target: target)
    }
    
    private func importLegacyCoreDataIfExist(in session: Session, target: BuildTarget) throws {
        let personalDataURL = try session.directory.storeURL(for: .personalData, in: target).appendingPathComponent("data.store")
        
        if FileManager.default.fileExists(atPath: personalDataURL.path) {
            try importLegacyCoreData(at: personalDataURL)
                        try FileManager.default.moveItem(at: personalDataURL, to: personalDataURL.appendingPathExtension("save"))
        }
    }
    
    private func migrateTimestampIfNeeded(in session: Session, target: BuildTarget) throws {
        let lastSyncTimestampURL = try session.lastSyncTimestampURL
        let oldStore = session.store(for: SyncService.SyncStoreKey.self)
        let newStore = BasicKeyedStore<SyncService.SyncStoreKey>(persistenceEngine: lastSyncTimestampURL)

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
            case .safari:
                self = .safariExtension
            case .authenticator:
                self = .authenticator
        }
    }
}
