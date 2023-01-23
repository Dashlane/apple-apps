import Foundation
import DashlaneCrypto
import CoreNetworking
import DashTypes
import CorePersonalData

public struct DocumentUploadError: Error {
    let message: String
    init(_ message: String) {
        self.message = message
    }
}

public enum UploadResult {
    case success
    case failure(Error)
}

public final class DocumentUpload: NSObject {

        private let plaintextUrl: URL

        private let encryptedUrl: URL

    public var item: () -> DocumentAttachable

        public var secureFileInfo: SecureFileInformation

        private let webservice: ProgressableNetworkingEngine

        private var streamEncrypt: StreamEncrypt?

        public private(set) var progress: Progress?

        let id = UUID().uuidString

        public let tag: String

    private(set) var isFinished: Bool = false

    private var backgroundActivity: NSObjectProtocol?

        private var task: URLSessionTask?

    private let documentCache: DocumentCache
    private let database: ApplicationDatabase
    let logger: DocumentStorageLogger

                                    init(url: URL,
         email: String,
         item: @escaping () -> DocumentAttachable,
         progress: Progress? = nil,
         tag: String = "unknown",
         database: ApplicationDatabase,
         documentCache: DocumentCache,
         webservice: ProgressableNetworkingEngine,
         logger: DocumentStorageLogger) throws {
        self.tag = tag
        self.progress = progress
        self.item = item
        self.plaintextUrl = url
        self.webservice = webservice
        self.documentCache = documentCache
        self.database = database
        self.logger = logger
        var secureFileInfo = SecureFileInformation()
        secureFileInfo.filename = url.lastPathComponent
        secureFileInfo.version = "1"
        secureFileInfo.localSize = "\(try FileInformation.size(ofFile: url))"
        secureFileInfo.type = FileInformation.mimeType(of: url) ?? "application/octet-stream"
        secureFileInfo.owner = email
        secureFileInfo.cryptoKey = ""
        secureFileInfo.downloadKey = ""
        self.secureFileInfo = secureFileInfo
        self.encryptedUrl = try documentCache.urlOfEncryptedDirectory(with: secureFileInfo.id.rawValue)
    }

    private func indicateBackgroudTaskEnd() {
        if let activity = self.backgroundActivity {
            ProcessInfo.processInfo.endActivity(activity)
        }
    }

                        public func requestUpload() async throws {
        do {
            if UInt64(secureFileInfo.remoteSize) == nil {
                try await encryptFile()
            }
            let auth = try await getUploadLink()
            try await upload(with: auth)
            try await commitFile()
        } catch {
            self.isFinished = true
            self.indicateBackgroudTaskEnd()
            throw error
        }
    }

    @discardableResult
    func encryptFile() async throws -> StreamTransfer {
        let streamTransfer: StreamTransfer = try await withCheckedThrowingContinuation { continuation in
            do {
                let cryptoKey = Random.randomData(ofSize: 32)
                self.secureFileInfo.cryptoKey = cryptoKey.base64EncodedString()
                let encrypt = try StreamEncrypt(source: plaintextUrl,
                                                       destination: encryptedUrl,
                                                       key: cryptoKey,
                                                       chunkSize: 2_000_000,
                                                       completionHandler: { result in
                    switch result {
                    case let .success(streamTransfer):
                        continuation.resume(with: .success(streamTransfer))
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                })

                let backgroundActivity = ProcessInfo.processInfo.beginActivity(options: [.userInitiated], reason: "DocumentUpload")
                self.backgroundActivity = backgroundActivity
                self.streamEncrypt = encrypt
                try encrypt.start()
            } catch {
                continuation.resume(throwing: error)
            }
        }
        let remoteFileSize = try FileInformation.size(ofFile: self.encryptedUrl)
        self.secureFileInfo.remoteSize = "\(remoteFileSize)"
        return streamTransfer
    }
}

extension DocumentUpload {

                private func getUploadLink() async throws -> UploadAuthentication {
        guard let remoteSize = UInt64(secureFileInfo.remoteSize) else {
            throw DocumentUploadError("Remote size should be already set at this point. If not, encryption may have failed")
        }
        let getAuthentication = GetUploadAuthenticationService(webservice: webservice)
        return try await getAuthentication.getLink(size: remoteSize, secureFileInfoId: secureFileInfo.id.rawValue)
    }

                        @discardableResult
    private func upload(with authentication: UploadAuthentication) async throws -> Bool {
        self.secureFileInfo.downloadKey = authentication.key
        let fileUploadService = FileUploadService(authentication: authentication, webservice: webservice)
        var progress: Progress?
        return try await withCheckedThrowingContinuation { continuation in
            do {
                self.task = try fileUploadService.upload(file: encryptedUrl, progress: &progress) { result in
                    switch result {
                    case .success(let result):
                        continuation.resume(with: .success(result))
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
                if let progress = progress {
                    self.progress?.addChild(progress, withPendingUnitCount: 1)
                }
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

        private func commitFile() async throws {
        let commitFileService = CommitFileService(webservice: webservice)
        try await commitFileService.commit(key: secureFileInfo.downloadKey,
                                           secureFileInfoId: secureFileInfo.id.rawValue)
        self.isFinished = true
        var editingItem = self.item()
        try editingItem.updateAttachments(with: self.secureFileInfo)
        try self.database.update(editingItem)
        _ = try self.database.save(self.secureFileInfo)
        self.logger.logAttachment(for: self.secureFileInfo, action: .add)
        try FileManager.default.removeItem(at: self.plaintextUrl)
        self.indicateBackgroudTaskEnd()
    }
}
