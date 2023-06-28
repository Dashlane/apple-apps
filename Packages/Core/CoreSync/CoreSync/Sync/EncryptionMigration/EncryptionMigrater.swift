import Foundation
import DashTypes

public class EncryptionMigrater<Delegate>  where Delegate: EncryptionMigraterDelegate {
    public typealias Output = Delegate.Output
    let decryptEngine: DecryptEngine
    let encryptEngine: EncryptEngine
    let getLatestEngine: DeprecatedCustomAPIClient
    let uploadContentEngine: DeprecatedCustomAPIClient
    let changePasswordDoneEngine: DeprecatedCustomAPIClient
    let authTicket: AuthTicket?
    let remoteKeys: [RemoteKey]?
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

    struct EmptyCodable: Codable {}

                                    public init(mode: MigrationUploadMode = .masterKeyChange,
                delegate: Delegate,
                decryptEngine: DecryptEngine,
                encryptEngine: EncryptEngine,
                database: MigrationCryptoDatabase,
                getLatestEngine: DeprecatedCustomAPIClient,
                uploadContentEngine: DeprecatedCustomAPIClient,
                changePasswordDoneEngine: DeprecatedCustomAPIClient,
                authTicket: AuthTicket?,
                remoteKeys: [RemoteKey]?,
                logger: Logger,
                cryptoSettings: CryptoRawConfig?) {
        self.mode = mode
        self.delegate = delegate
        self.decryptEngine = decryptEngine
        self.encryptEngine = encryptEngine
        self.database = database
        self.getLatestEngine = getLatestEngine
        self.uploadContentEngine = uploadContentEngine
        self.changePasswordDoneEngine = changePasswordDoneEngine
        self.authTicket = authTicket
        self.remoteKeys = remoteKeys
        self.cryptoSettings = cryptoSettings
        self.logger = logger
    }

    public convenience init(mode: MigrationUploadMode = .masterKeyChange,
                            delegate: Delegate,
                            decryptEngine: DecryptEngine,
                            encryptEngine: EncryptEngine,
                            database: MigrationCryptoDatabase,
                            signatureBasedNetworkingEngine: DeprecatedCustomAPIClient,
                            authTicket: AuthTicket?,
                            remoteKeys: [RemoteKey]?,
                            cryptoSettings: CryptoRawConfig?,
                            logger: Logger) {
        self.init(mode: mode,
                  delegate: delegate,
                  decryptEngine: decryptEngine,
                  encryptEngine: encryptEngine,
                  database: database,
                  getLatestEngine: signatureBasedNetworkingEngine,
                  uploadContentEngine: signatureBasedNetworkingEngine,
                  changePasswordDoneEngine: signatureBasedNetworkingEngine,
                  authTicket: authTicket,
                  remoteKeys: remoteKeys,
                  logger: logger,
                  cryptoSettings: cryptoSettings)
    }
            public func start() {
        self.delegate?.didProgress(.downloading(.inProgress(completedFraction: 0)))
        downloadAllTransactions { [weak self] (result) in
            guard let self = self else { return }

            self.delegate?.didProgress(.downloading(.completed))

            do {
                let downloadedDataContainer = try result.get()
                self.reEncryptAndUpload(downloadedDataContainer)
            } catch {
                self.delegate?.didFinish(with: .failure(MigraterError(step: .downloading, internalError: error)))
            }
        }
    }

        private func downloadAllTransactions(completion: @escaping (Result<AllDataForMasterPasswordChange, Swift.Error>) -> Void) {
        GetLatestDataService.fetchAllDataForMasterPasswordChange(using: getLatestEngine,
                                                               completion: completion)
    }

    private func reEncryptAndUpload(_ downloadedDataContainer: AllDataForMasterPasswordChange) {
        do {
            let sharingKeys = SharingKeys(downloadedDataContainer.data.sharingKeys)

            let downloadedTransactions = downloadedDataContainer.data.transactions
            let transactionsCount = downloadedTransactions.count

            let keepEditTransactions: (DownloadedTransaction) -> Bool = { $0.action == .edit }

                        let reEncryptedTransactions = try downloadedTransactions
                .filter(keepEditTransactions).enumerated()
                .compactMap { (enumeratedTransaction) -> DownloadedTransaction? in
                    let (offset, transaction) = enumeratedTransaction
                    let completedFraction = Progression.State.inProgress(completedFraction: Double(offset) / Double(transactionsCount))
                    self.delegate?.didProgress(.decrypting(completedFraction))

                    return try transaction.transformContent(from: self.decryptEngine,
                                                            to: self.encryptEngine,
                                                            database: database,
                                                            logger: self.logger,
                                                            cryptoSettings: self.cryptoSettings)
                }

            self.delegate?.didProgress(.reEncrypting(.inProgress(completedFraction: 0)) )

            let reEncryptedSharingKeys = try sharingKeys?.convertCrypto(from: self.decryptEngine,
                                                                       to: self.encryptEngine)

                        let reEncryptedSyncTransactions = reEncryptedTransactions.map { $0.syncTransaction }
            self.delegate?.didProgress(.uploading(.inProgress(completedFraction: 0)) )

                        self.uploadAll(transactions: reEncryptedSyncTransactions,
                           timestamp: downloadedDataContainer.timestamp,
                           sharingKeys: reEncryptedSharingKeys)

        } catch {
            self.delegate?.didFinish(with: .failure(MigraterError(step: .reEncrypting, internalError: error)))
        }
    }

            private func uploadAll(transactions: [UploadTransaction],
                           timestamp: Timestamp,
                           sharingKeys: SharingKeys?) {
        let transactionIDs = transactions.map { $0.identifier }
        let data = DataForMasterPasswordChange(timestamp: timestamp,
                                               new2FASetting: nil,
                                               sharingKeys: sharingKeys,
                                               transactions: transactions,
                                               authTicket: authTicket?.token,
                                               remoteKeys: remoteKeys,
                                               updateVerification: authTicket?.verification)
        UploadContentService.upload(using: mode,
                                    content: data,
                                    authenticatedAPIClient: uploadContentEngine) { [weak self] result in
            guard let self = self else {
                return
            }
            do {
                self.delegate?.didProgress(.uploading(.completed))
                let timestamp = try result.get()
                try self.database.updateSyncTimestamp(timestamp, for: transactionIDs)
                if let cryptoSettings = self.cryptoSettings {
                    try self.database.save(cryptoSettings)
                }

                self.delegate?.complete(with: timestamp) { result in
                    switch result {
                    case  let .success(output):
                        self.completeProcess(with: output)
                    case let .failure(error):
                        self.delegate?.didFinish(with: .failure(MigraterError(step: .delegateCompleting, internalError: error)))
                    }
                }
            } catch {
                self.delegate?.didFinish(with: .failure(MigraterError(step: .uploading, internalError: error)))
            }
        }
    }

    private func completeProcess(with output: Output) {
        delegate?.didProgress(.finalizing)
        switch mode {
        case .masterKeyChange:
            changeMasterKeyDone { [ weak self] result in
                self?.delegate?.didFinish(with: result
                                            .map { output }
                                            .mapError { MigraterError(step: .notifyingMasterKeyDone, internalError: $0) })
            }
        case .cryptoConfigChange:
            delegate?.didFinish(with: .success(output))
        }
    }

        private func changeMasterKeyDone(completion: @escaping (Result<Void, Swift.Error>) -> Void) {
        changePasswordDoneEngine.sendRequest(to: "v1/sync/ConfirmMasterPasswordChangeDone",
                                             using: HTTPMethod.post,
                                             input: EmptyCodable()) { (result: Result<EmptyCodable, Swift.Error>) in
                                                completion(result.map { _ in Void() })
        }

    }
}

struct CryptoConverterHelper {
    enum Error: Swift.Error {
        case invalidData
        case failedReEncrypting
        case couldNotDecryptData
    }
    static func reEncrypt(stringData: String,
                          from decryptEngine: DecryptEngine,
                          to encryptEngine: EncryptEngine) throws -> String? {
                guard let encryptedData = Data(base64Encoded: stringData)  else {
            throw Error.invalidData
        }
                guard let decryptedData = decryptEngine.decrypt(data: encryptedData) else {
            throw Error.couldNotDecryptData
        }
                guard let reEncryptedData = encryptEngine.encrypt(data: decryptedData) else {
            throw Error.failedReEncrypting
        }
        return reEncryptedData.base64EncodedString()
    }
}
private extension DownloadedTransaction {
    enum CryptoConverterError: Error {
        case invalidData
        case failedReEncrypting(id: Identifier, specificError: Error)

                case invalidAction
    }

    func transformContent(from decryptEngine: DecryptEngine,
                          to encryptEngine: EncryptEngine,
                          database: MigrationCryptoDatabase,
                          logger: Logger,
                          cryptoSettings: CryptoRawConfig?) throws -> DownloadedTransaction? {
        guard self.action == .edit else {
            throw CryptoConverterError.invalidAction
        }
        guard let content = content else {
            return DownloadedTransaction(action: .edit,
                               backupDate: self.backupDate,
                               content: nil,
                               identifier: self.identifier,
                               type: .init(rawValue: $type))
        }
        do {
            if let cryptoSettings = cryptoSettings, self.type == .settings, let content = Data(base64Encoded: content) {
                let content = try content.decrypt(using: decryptEngine)
                let newContent = try database.updateSettingsTransactionContent(content, with: cryptoSettings)
                    .encrypt(using: encryptEngine)

                return DownloadedTransaction(action: .edit,
                                   backupDate: self.backupDate,
                                             content: newContent.base64EncodedString(),
                                   identifier: self.identifier,
                                   type: .init(rawValue: $type))
            }
            let newContent = try CryptoConverterHelper.reEncrypt(stringData: content,
                                                                 from: decryptEngine,
                                                                 to: encryptEngine)
                        return DownloadedTransaction(action: .edit,
                               backupDate: self.backupDate,
                               content: newContent,
                               identifier: self.identifier,
                               type: .init(rawValue: $type))
        } catch let error where type == .settings {
            throw CryptoConverterError.failedReEncrypting(id: identifier, specificError: error)
        } catch {
                        logger.error("Cannot reencrypt transaction \($type)>\(identifier.rawValue): \(error)")
            return nil
        }
    }

    var syncTransaction: UploadTransaction {
        let syncTransaction = UploadTransaction(action: .edit,
                                              content: self.content,
                                              identifier: self.identifier,
                                              type: .init(rawValue: $type))
        return syncTransaction
    }
}

public enum MigrationKeysError: Swift.Error {
    case missingKeys
    case failedDecryptingPrivateKey
    case failedReEncryptingPrivateKey
}

private extension SharingKeys {

    func convertCrypto(from decryptEngine: DecryptEngine,
                       to encryptEngine: EncryptEngine) throws -> SharingKeys {
        guard let encryptedPrivateKeyData = Data.init(base64Encoded: encryptedPrivateKey),
            let privateKey = decryptEngine.decrypt(data: encryptedPrivateKeyData)
            else {
                throw MigrationKeysError.failedDecryptingPrivateKey
        }

        guard let reEncryptedPrivatekey = encryptEngine.encrypt(data: privateKey)
            else {
                throw MigrationKeysError.failedReEncryptingPrivateKey
        }
        return SharingKeys(publicKey: self.publicKey, encryptedPrivateKey: reEncryptedPrivatekey.base64EncodedString())
    }
}
