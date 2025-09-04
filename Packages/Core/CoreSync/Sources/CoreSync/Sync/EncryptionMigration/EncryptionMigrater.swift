import Combine
import CoreTypes
import DashlaneAPI
import Foundation
import LogFoundation

public typealias AllDataForMasterPasswordChange = UserDeviceAPIClient.Sync
  .GetDataForMasterPasswordChange.Response
public typealias DownloadedTransactions = UserDeviceAPIClient.Sync.GetLatestContent.Response

public class EncryptionMigrater {
  let cryptoEngine: CryptoChangerEngine
  let apiClient: UserDeviceAPIClient
  let authTicket: AuthTicket?
  let remoteKeys: SyncUploadDataRemoteKeys?
  let cryptoSettings: CryptoRawConfig?
  let logger: Logger
  let mode: MigrationUploadMode
  let database: MigrationCryptoDatabase
  private var progression: Progression = .downloading
  public var progressionPublisher = PassthroughSubject<Progression, Never>()

  @Loggable
  public enum Progression: Sendable {
    case downloading
    case decrypting
    case encrypting
    case uploading
    case finalizing
  }

  @Loggable
  public struct MigrationError: Error {
    public let progression: Progression
    public let internalError: Error
  }

  public init(
    mode: MigrationUploadMode = .masterKeyChange,
    cryptoEngine: CryptoChangerEngine,
    database: MigrationCryptoDatabase,
    apiClient: UserDeviceAPIClient,
    authTicket: AuthTicket?,
    remoteKeys: SyncUploadDataRemoteKeys?,
    cryptoSettings: CryptoRawConfig?,
    logger: Logger
  ) {
    self.mode = mode
    self.cryptoEngine = cryptoEngine
    self.database = database
    self.apiClient = apiClient
    self.authTicket = authTicket
    self.remoteKeys = remoteKeys
    self.cryptoSettings = cryptoSettings
    self.logger = logger
  }

  public func startMigration() async throws(MigrationError) -> Timestamp {
    do {
      report(progression: .downloading)
      let dataContainer = try await apiClient.sync.getDataForMasterPasswordChange()

      let transactions = try await self.decrypt(dataContainer)

      let keys = try await encrypt(keys: dataContainer.data.sharingKeys)

      let timestamp = Timestamp(dataContainer.timestamp)

      try await uploadAll(
        transactions,
        timestamp: timestamp,
        sharingKeys: keys
      )

      report(progression: .finalizing)

      return timestamp
    } catch {
      throw MigrationError(progression: progression, internalError: error)
    }
  }

  public func completeMigration() async throws(MigrationError) {
    do {
      if case .masterKeyChange = mode {
        try await changeMasterKeyDone()
      }
    } catch {
      throw MigrationError(progression: progression, internalError: error)
    }
  }

  private func decrypt(_ downloadedDataContainer: AllDataForMasterPasswordChange) async throws
    -> [UploadMigrationTransaction]
  {
    report(progression: .decrypting)
    let downloadedTransactions = downloadedDataContainer.data.transactions

    let keepEditTransactions:
      (
        UserDeviceAPIClient.Sync.GetDataForMasterPasswordChange.Response.DataValue
          .TransactionsElement
      ) -> Bool = {
        $0.action == .backupEdit
      }

    var reEncryptedTransactions = [UploadMigrationTransaction]()

    for transaction in downloadedTransactions.filter(keepEditTransactions) {

      if let transaction = try transaction.transformContent(
        using: cryptoEngine,
        database: database,
        logger: self.logger,
        cryptoSettings: self.cryptoSettings
      ) {
        reEncryptedTransactions.append(transaction)
      }
    }

    return reEncryptedTransactions
  }

  private func encrypt(keys: SyncSharingKeys) async throws -> SyncSharingKeys {
    report(progression: .encrypting)
    return SyncSharingKeys(
      privateKey: try cryptoEngine.recryptBase64Encoded(keys.privateKey),
      publicKey: keys.publicKey
    )
  }

  private func uploadAll(
    _ transactions: [UploadMigrationTransaction],
    timestamp: Timestamp,
    sharingKeys: SyncSharingKeys
  ) async throws {
    report(progression: .uploading)
    let data = DataForMasterPasswordChange(
      timestamp: timestamp,
      new2FASetting: nil,
      sharingKeys: sharingKeys,
      transactions: transactions,
      authTicket: authTicket?.token,
      remoteKeys: remoteKeys,
      updateVerification: authTicket?.verification
    )

    try await Task.sleep(for: .milliseconds(1100))
    let response = try await apiClient.sync.upload(using: mode, content: data)

    let timestamp = Timestamp(response.timestamp)
    let transactionIDs = transactions.map { Identifier($0.identifier) }
    try self.database.updateSyncTimestamp(timestamp, for: transactionIDs)

    if let cryptoSettings = self.cryptoSettings {
      try self.database.save(cryptoSettings)
    }
  }

  private func changeMasterKeyDone() async throws {
    _ = try await apiClient.sync.confirmMasterPasswordChangeDone()
  }

  private func report(progression: Progression) {
    self.progression = progression
    progressionPublisher.send(progression)
  }
}

extension UserDeviceAPIClient.Sync.GetDataForMasterPasswordChange.Response.DataValue
  .TransactionsElement
{
  @Loggable
  fileprivate enum CryptoConverterError: Error {
    case invalidData
    case failedReEncrypting(id: Identifier, specificError: Error)

    case invalidAction
  }

  fileprivate func transformContent(
    using cryptoEngine: CryptoChangerEngine,
    database: MigrationCryptoDatabase,
    logger: Logger,
    cryptoSettings: CryptoRawConfig?
  ) throws -> UploadMigrationTransaction? {

    guard self.action == .backupEdit else {
      throw CryptoConverterError.invalidAction
    }

    let type = PersonalDataContentType(rawValue: type)

    do {
      if type == .settings, let cryptoSettings = cryptoSettings,
        let content = Data(base64Encoded: content)
      {
        let content = try content.decrypt(using: cryptoEngine)
        let newContent = try database.updateSettingsTransactionContent(
          content, with: cryptoSettings
        )
        .encrypt(using: cryptoEngine)

        return UploadMigrationTransaction(
          identifier: identifier,
          time: time,
          content: newContent.base64EncodedString(),
          type: self.type,
          action: .backupEdit)
      } else {
        return UploadMigrationTransaction(
          identifier: identifier,
          time: time,
          content: try cryptoEngine.recryptBase64Encoded(content),
          type: self.type,
          action: .backupEdit)
      }

    } catch let error where type == .settings {
      throw CryptoConverterError.failedReEncrypting(
        id: Identifier(identifier), specificError: error)
    } catch {
      logger.error("Cannot reencrypt transaction \(self.type)>\(identifier): \(error)")
      return nil
    }
  }
}
