import Combine
import DashTypes
import DashlaneAPI
import Foundation

public typealias AllDataForMasterPasswordChange = UserDeviceAPIClient.Sync
  .GetDataForMasterPasswordChange.Response
public typealias DownloadedTransactions = UserDeviceAPIClient.Sync.GetLatestContent.Response

public class EncryptionMigrater<Delegate: EncryptionMigraterDelegate> {
  public typealias Output = Delegate.Output

  let decryptEngine: DecryptEngine
  let encryptEngine: EncryptEngine
  let apiClient: UserDeviceAPIClient
  let authTicket: AuthTicket?
  let remoteKeys: [SyncUploadDataRemoteKeys]?
  let cryptoSettings: CryptoRawConfig?
  let logger: Logger
  let mode: MigrationUploadMode
  let database: MigrationCryptoDatabase
  weak var delegate: Delegate?

  public enum Progression {
    public enum State {
      case inProgress(completedFraction: Double)
      case completed
    }

    case downloading(_ state: State)
    case decrypting(_ state: State)
    case reEncrypting(_ state: State)
    case uploading(_ state: State)
    case finalizing
  }

  public struct MigraterError: Error {
    public enum Step {
      case downloading
      case reEncrypting
      case uploading
      case delegateCompleting
      case notifyingMasterKeyDone
    }

    public let step: Step
    public let internalError: Error
  }

  public init(
    mode: MigrationUploadMode = .masterKeyChange,
    delegate: Delegate,
    decryptEngine: DecryptEngine,
    encryptEngine: EncryptEngine,
    database: MigrationCryptoDatabase,
    apiClient: UserDeviceAPIClient,
    authTicket: AuthTicket?,
    remoteKeys: [SyncUploadDataRemoteKeys]?,
    logger: Logger,
    cryptoSettings: CryptoRawConfig?
  ) {
    self.mode = mode
    self.delegate = delegate
    self.decryptEngine = decryptEngine
    self.encryptEngine = encryptEngine
    self.database = database
    self.apiClient = apiClient
    self.authTicket = authTicket
    self.remoteKeys = remoteKeys
    self.cryptoSettings = cryptoSettings
    self.logger = logger
  }

  public convenience init(
    mode: MigrationUploadMode = .masterKeyChange,
    delegate: Delegate,
    decryptEngine: DecryptEngine,
    encryptEngine: EncryptEngine,
    database: MigrationCryptoDatabase,
    apiClient: UserDeviceAPIClient,
    authTicket: AuthTicket?,
    remoteKeys: [SyncUploadDataRemoteKeys]?,
    cryptoSettings: CryptoRawConfig?,
    logger: Logger
  ) {
    self.init(
      mode: mode,
      delegate: delegate,
      decryptEngine: decryptEngine,
      encryptEngine: encryptEngine,
      database: database,
      apiClient: apiClient,
      authTicket: authTicket,
      remoteKeys: remoteKeys,
      logger: logger,
      cryptoSettings: cryptoSettings
    )
  }

  public func start() async {
    do {
      await self.delegate?.didProgress(.downloading(.inProgress(completedFraction: 0)))
      let dataContainer = try await apiClient.sync.getDataForMasterPasswordChange()
      await self.delegate?.didProgress(.downloading(.completed))
      await self.reEncryptAndUpload(dataContainer)
    } catch {
      await self.delegate?.didFinish(
        with: .failure(MigraterError(step: .downloading, internalError: error)))
    }
  }

  private func reEncryptAndUpload(_ downloadedDataContainer: AllDataForMasterPasswordChange) async {
    do {
      let sharingKeys = downloadedDataContainer.data.sharingKeys
      let downloadedTransactions = downloadedDataContainer.data.transactions
      let transactionsCount = downloadedTransactions.count

      let keepEditTransactions:
        (
          UserDeviceAPIClient.Sync.GetDataForMasterPasswordChange.Response.DataValue
            .TransactionsElement
        ) -> Bool = {
          $0.action == .backupEdit
        }

      var reEncryptedTransactions = [UploadMigrationTransaction]()

      for (offset, transaction) in downloadedTransactions.filter(keepEditTransactions).enumerated()
      {
        let completedFraction = Double(offset) / Double(transactionsCount)
        await delegate?.didProgress(.decrypting(.inProgress(completedFraction: completedFraction)))

        if let transaction = try transaction.transformContent(
          from: self.decryptEngine,
          to: self.encryptEngine,
          database: database,
          logger: self.logger,
          cryptoSettings: self.cryptoSettings
        ) {
          reEncryptedTransactions.append(transaction)
        }
      }
      await delegate?.didProgress(.decrypting(.completed))

      await delegate?.didProgress(.reEncrypting(.inProgress(completedFraction: 0)))
      let reEncryptedSharingKeys = try sharingKeys.convertCrypto(
        from: self.decryptEngine,
        to: self.encryptEngine
      )
      await delegate?.didProgress(.reEncrypting(.completed))

      await delegate?.didProgress(.uploading(.inProgress(completedFraction: 0)))
      await self.uploadAll(
        reEncryptedTransactions,
        timestamp: Timestamp(downloadedDataContainer.timestamp),
        sharingKeys: reEncryptedSharingKeys)
      await delegate?.didProgress(.uploading(.completed))
    } catch {
      await self.delegate?.didFinish(
        with: .failure(MigraterError(step: .reEncrypting, internalError: error)))
    }
  }

  private func uploadAll(
    _ transactions: [UploadMigrationTransaction],
    timestamp: Timestamp,
    sharingKeys: SyncSharingKeys
  ) async {
    let data = DataForMasterPasswordChange(
      timestamp: timestamp,
      new2FASetting: nil,
      sharingKeys: sharingKeys,
      transactions: transactions,
      authTicket: authTicket?.token,
      remoteKeys: remoteKeys,
      updateVerification: authTicket?.verification)

    do {

      try await Task.sleep(for: .milliseconds(1100))
      let response = try await apiClient.sync.upload(using: mode, content: data)

      let timestamp = Timestamp(response.timestamp)
      let transactionIDs = transactions.map { Identifier($0.identifier) }
      try self.database.updateSyncTimestamp(timestamp, for: transactionIDs)

      if let cryptoSettings = self.cryptoSettings {
        try self.database.save(cryptoSettings)
      }

      await self.delegate?.complete(with: timestamp) { result in
        switch result {
        case let .success(output):
          await self.completeProcess(with: output)
        case let .failure(error):
          self.delegate?.didFinish(
            with: .failure(MigraterError(step: .delegateCompleting, internalError: error)))
        }
      }

    } catch {
      await self.delegate?.didFinish(
        with: .failure(MigraterError(step: .uploading, internalError: error)))
    }
  }

  private func completeProcess(with output: Output) async {
    await delegate?.didProgress(.finalizing)
    switch mode {
    case .masterKeyChange:
      do {
        try await changeMasterKeyDone()
        await delegate?.didFinish(with: .success(output))
      } catch {
        await delegate?.didFinish(
          with: .failure(MigraterError(step: .notifyingMasterKeyDone, internalError: error)))
      }
    case .cryptoConfigChange:
      await delegate?.didFinish(with: .success(output))
    }
  }

  private func changeMasterKeyDone() async throws {
    _ = try await apiClient.sync.confirmMasterPasswordChangeDone()
  }
}

struct CryptoConverterHelper {
  enum Error: Swift.Error {
    case invalidData
    case failedReEncrypting
    case couldNotDecryptData
  }

  static func reEncrypt(
    _ stringData: String,
    from decryptEngine: DecryptEngine,
    to encryptEngine: EncryptEngine
  ) throws -> String {
    guard let encryptedData = Data(base64Encoded: stringData) else {
      throw Error.invalidData
    }
    guard let decryptedData = try? decryptEngine.decrypt(encryptedData) else {
      throw Error.couldNotDecryptData
    }
    guard let reEncryptedData = try? encryptEngine.encrypt(decryptedData) else {
      throw Error.failedReEncrypting
    }
    return reEncryptedData.base64EncodedString()
  }
}
extension UserDeviceAPIClient.Sync.GetDataForMasterPasswordChange.Response.DataValue
  .TransactionsElement
{
  fileprivate enum CryptoConverterError: Error {
    case invalidData
    case failedReEncrypting(id: Identifier, specificError: Error)

    case invalidAction
  }

  fileprivate func transformContent(
    from decryptEngine: DecryptEngine,
    to encryptEngine: EncryptEngine,
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
        let content = try content.decrypt(using: decryptEngine)
        let newContent = try database.updateSettingsTransactionContent(
          content, with: cryptoSettings
        )
        .encrypt(using: encryptEngine)

        return UploadMigrationTransaction(
          identifier: identifier,
          time: time,
          content: newContent.base64EncodedString(),
          type: self.type,
          action: .backupEdit)
      } else {
        let newContent = try CryptoConverterHelper.reEncrypt(
          content, from: decryptEngine, to: encryptEngine)

        return UploadMigrationTransaction(
          identifier: identifier,
          time: time,
          content: newContent,
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

public enum MigrationKeysError: Swift.Error {
  case missingKeys
  case failedDecryptingPrivateKey
  case failedReEncryptingPrivateKey
}

extension SyncSharingKeys {

  fileprivate func convertCrypto(from decryptEngine: DecryptEngine, to encryptEngine: EncryptEngine)
    throws -> SyncSharingKeys
  {
    guard let encryptedPrivateKeyData = Data.init(base64Encoded: privateKey),
      let privateKey = try? decryptEngine.decrypt(encryptedPrivateKeyData)
    else {
      throw MigrationKeysError.failedDecryptingPrivateKey
    }

    guard let reEncryptedPrivatekey = try? encryptEngine.encrypt(privateKey) else {
      throw MigrationKeysError.failedReEncryptingPrivateKey
    }

    return SyncSharingKeys(
      privateKey: reEncryptedPrivatekey.base64EncodedString(), publicKey: self.publicKey)
  }
}
