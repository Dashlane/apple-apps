import CoreTypes
import Foundation

public struct MigrationCryptoDBStack: MigrationCryptoDatabase {
  let driver: DatabaseDriver

  public init(driver: DatabaseDriver) {
    self.driver = driver
  }

  public func updateSettingsTransactionContent(_ content: Data, with config: CryptoRawConfig) throws
    -> Data
  {
    var settings = try Settings.makeSettings(compressedContent: content)
    settings.cryptoConfig = config
    return try settings.makeTransactionContent()
  }

  public func updateSyncTimestamp(_ timestamp: Timestamp, for ids: [Identifier]) throws {
    try driver.write { db in
      let allMetadata = try db.fetchAllMetadata(with: ids)

      for var metadata in allMetadata {
        metadata.lastSyncTimestamp = timestamp
        try db.update(metadata)
      }
    }
  }

  public func save(_ cryptoConfig: CryptoRawConfig) throws {
    try driver.write { db in
      guard var record = try db.fetchOne(with: Settings.id) else {
        return
      }

      var settings = try PersonalDataDecoder().decode(Settings.self, from: record)
      settings.cryptoConfig = cryptoConfig
      record.content = try PersonalDataEncoder().encode(settings, in: record.content)

      try db.save(record, shouldCreateSnapshot: true)
    }
  }
}
