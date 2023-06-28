import Foundation
import CorePersonalData
import DashTypes
import Combine
import CoreNetworking

public final class DocumentStorageService {
    @Published
    public var uploads: [DocumentUpload] = []

    @Published
    public private(set) var downloads: [DocumentDownload] = []

        public let documentCache: DocumentCache = DocumentCache()
    public let documentDeleteService: DocumentDeleteService
    let database: ApplicationDatabase
    let webservice: ProgressableNetworkingEngine
    let login: Login

    public init(database: ApplicationDatabase,
                webservice: ProgressableNetworkingEngine,
                login: Login) {
        self.database = database
        self.webservice = webservice
        self.documentDeleteService = DocumentDeleteService(database: database,
                                                           webservice: webservice)
        self.login = login
    }

                private func add(_ upload: DocumentUpload) {
        DispatchQueue.main.async {
            self.uploads.append(upload)
        }
    }

                private func add(_ download: DocumentDownload) {
        DispatchQueue.main.async {
            self.downloads.append(download)
        }
    }

                private func removeCompletedUpload(with tag: String) {
        guard let index = uploads.firstIndex(where: { $0.tag == tag && $0.isFinished == true }) else {
            return
        }
        DispatchQueue.main.async {
            self.uploads.remove(at: index)
        }
    }

                private func removeDownload(with id: String) {
        DispatchQueue.main.async {
            if let index = self.downloads.firstIndex(where: { $0.id == id }) {
                self.downloads.remove(at: index)
            }
        }
    }

                    public func download(with id: String) -> DocumentDownload? {
        return downloads.first { $0.attachment.id == id }
    }

                    public func upload(with attachment: Attachment) -> DocumentUpload? {
        return uploads.first { $0.secureFileInfo.id.rawValue == attachment.id }
    }

                    public func upload(with tag: String) -> DocumentUpload? {
        return uploads.first { $0.tag == tag }
    }

                    public func uploads(with item: DocumentAttachable) -> [DocumentUpload] {
        return uploads.filter { $0.item().id == item.id }
    }

        public func unload() {
        try? self.documentCache.clear(.allDirectories)
    }
}

public extension DocumentStorageService {
    func upload(_ fileURL: URL,
                progress: Progress,
                item: @escaping () -> DocumentAttachable,
                tag: String) async throws {
        let documentUpload = try DocumentUpload(url: fileURL,
                                                email: login.email,
                                                item: item,
                                                progress: progress,
                                                tag: tag,
                                                database: database,
                                                documentCache: documentCache,
                                                webservice: webservice)
        try await documentUpload.encryptFile()
        add(documentUpload)
        defer {
            self.removeCompletedUpload(with: tag)
        }
        try await documentUpload.requestUpload()
    }

                            func download(_ attachment: Attachment, progress: Progress? = nil) async throws -> URL {
        let documentDownload = try DocumentDownload(attachment,
                                                    progress: progress,
                                                    webservice: webservice,
                                                    documentCache: documentCache,
                                                    isFileAvailableLocally: isFileAvailableLocally(for:))
        add(documentDownload)
        let downloadId = documentDownload.id
        do {
            let downloadedFileURL = try await documentDownload.requestDownload()
            self.removeDownload(with: downloadId)
            return downloadedFileURL
        } catch {
            self.removeDownload(with: downloadId)
            throw error
        }
    }

                func isFileAvailableLocally(for attachment: Attachment) throws -> Bool {
        guard let downloadedFileURL = try? documentCache.urlOfEncryptedDirectory(with: attachment.id) else {
            return false
        }
        guard let size = try? FileInformation.size(ofFile: downloadedFileURL) else {
            return false
        }
        guard attachment.remoteSize == size else {
            throw DocumentDownloadError("Actual filesize \(size) does not match value defined in Attachment \(attachment.remoteSize)")
        }
        return true
    }

        func fileURL(for attachment: Attachment) throws -> URL? {
        guard let downloadedFileURL = try? documentCache.urlOfEncryptedDirectory(with: attachment.id) else {
            return nil
        }
        guard let size = try? FileInformation.size(ofFile: downloadedFileURL) else {
            return nil
        }
        guard attachment.remoteSize == size else {
            throw DocumentDownloadError("Actual filesize \(size) does not match value defined in Attachment \(attachment.remoteSize)")
        }
        return downloadedFileURL
    }
}

public extension DocumentStorageService {
    static var mock: DocumentStorageService {
        .init(database: ApplicationDBStack.mock(),
              webservice: LegacyWebServiceImpl(serverConfiguration: .init(platform: .passwordManagerIphone)),
              login: .init("_"))
    }
}
