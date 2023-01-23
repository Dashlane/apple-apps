import Foundation
import DashlaneCrypto
import CoreNetworking
import DashTypes
import CorePersonalData

struct DocumentDownloadError: Error {
    let message: String
    init(_ message: String) {
        self.message = message
    }
}

public final class DocumentDownload: NSObject {

                    public enum DocumentDownloadResult {
        case success(URL)
        case failure(Error)
    }

        public let attachment: Attachment

        var streamDecrypt: StreamDecrypt?

        let downloadedFileURL: URL

        let decryptedFileURL: URL

        public var completionHandler: ((DocumentDownloadResult) -> Void)?

        private let webservice: ProgressableNetworkingEngine

        public private(set) var progress: Progress?

        private var task: URLSessionDownloadTask?

        let id = UUID().uuidString

    let documentCache: DocumentCache

    private var backgroundActivity: NSObjectProtocol?

    private let isFileAvailableLocally: (Attachment) throws -> Bool

                                init(_ attachment: Attachment,
         progress: Progress? = nil,
         webservice: ProgressableNetworkingEngine,
         documentCache: DocumentCache,
         isFileAvailableLocally: @escaping (Attachment) throws -> Bool) throws {
        self.attachment = attachment
        self.progress = progress
        self.documentCache = documentCache
        self.downloadedFileURL = try documentCache.urlOfEncryptedDirectory(with: attachment.id)
        self.decryptedFileURL = try documentCache.urlOfDecryptedDirectory(with: attachment.id)
        self.webservice = webservice
        self.isFileAvailableLocally = isFileAvailableLocally
    }

    private func indicateBackgroudTaskEnd() {
        if let backgroundActivity = backgroundActivity {
            ProcessInfo.processInfo.endActivity(backgroundActivity)
        }
    }

        private lazy var urlSession: URLSession = {
        let configuration = URLSessionConfiguration.ephemeral
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()

                    public func requestDownload() async throws -> URL {
        self.backgroundActivity = ProcessInfo.processInfo.beginActivity(options: [.userInitiated], reason: "DocumentDownload")
        if try isFileAvailableLocally(attachment) {
            let url = try await decryptFile()
            indicateBackgroudTaskEnd()
            progress?.cancel()
            return url
        } else {
            let link = try await GetDownloadLinkService(webservice: webservice)
                .getLink(key: attachment.downloadKey, secureFileInfoId: attachment.id)
            return try await self.download(from: link)
        }
    }
    
    private func decryptFile() async throws -> URL {
        guard let cryptoKey = Data(base64Encoded: attachment.cryptoKey) else {
            throw DocumentDownloadError("cryptoKey is not base64 string")
        }
        let _decryptedFileURL = self.decryptedFileURL
        let _downloadedFileURL = self.downloadedFileURL
        
        return try await withCheckedThrowingContinuation { continuation in
            do {
                self.streamDecrypt = try StreamDecrypt(source: _downloadedFileURL, destination: _decryptedFileURL, key: cryptoKey, chunkSize: 2_000_000) { result in
                    switch result {
                    case .success:
                        continuation.resume(with: .success(_decryptedFileURL))
                    case .failure(let error):
                        continuation.resume(throwing: error)
                    }
                }
                try self.streamDecrypt?.start()
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }

            private func download(from downloadLink: DownloadLink) async throws -> URL {
        try await withCheckedThrowingContinuation { continuation in
            let downloadTask = self.urlSession.downloadTask(with: downloadLink.url) { [weak self] url, _, error in
                guard let self = self else { return }
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let url = url {
                    do {
                        let downloadedFilesize = Int(try FileInformation.size(ofFile: url))
                        guard self.attachment.remoteSize == downloadedFilesize else {
                            continuation.resume(throwing: DocumentDownloadError("Remote file is an unexpected size"))
                            return
                        }
                        try? FileManager.default.removeItem(at: self.downloadedFileURL)
                        try FileManager.default.moveItem(at: url, to: self.downloadedFileURL)

                        Task {
                            do {
                                let url = try await self.decryptFile()
                                continuation.resume(with: .success(url))
                            } catch {
                                continuation.resume(throwing: error)
                            }
                        }
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
            }
            self.task = downloadTask
            self.progress?.addChild(downloadTask.progress, withPendingUnitCount: 1)
            downloadTask.resume()
            self.urlSession.finishTasksAndInvalidate()
        }
    }
    
    private func handleError(_ error: Error) {
        self.progress?.cancel()
        self.completionHandler?(.failure(error))
        self.indicateBackgroudTaskEnd()
    }
}

extension DocumentDownload: URLSessionDelegate {
    public func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Swift.Void) {
        completionHandler(.performDefaultHandling, nil)
    }
}
