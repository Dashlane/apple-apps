import Foundation

public protocol MigrationCryptoDatabase {
  func updateSettingsTransactionContent(_ content: Data, with config: CryptoRawConfig) throws
    -> Data
  func updateSyncTimestamp(_ timestamp: Timestamp, for ids: [Identifier]) throws
  func save(_ cryptoConfig: CryptoRawConfig) throws
}
