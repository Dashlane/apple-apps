import CoreNetworking
import CorePersonalData
import CoreTypes
import DashlaneAPI
import Foundation
import LogFoundation

@Loggable
struct DocumentDownloadError: Error {
  @LogPublicPrivacy
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

  let downloadedFileURL: URL

  let decryptedFileURL: URL

  private var cryptoProvider: DocumentCryptoProvider

  public var completionHandler: ((DocumentDownloadResult) -> Void)?

  private let userDeviceAPIClient: UserDeviceAPIClient

  public private(set) var progress: Progress?

  private var task: URLSessionDownloadTask?

  let id = UUID().uuidString

  let documentCache: DocumentCache

  private var backgroundActivity: NSObjectProtocol?

  private let isFileAvailableLocally: (Attachment) throws -> Bool

  init(
    _ attachment: Attachment,
    progress: Progress? = nil,
    userDeviceAPIClient: UserDeviceAPIClient,
    cryptoProvider: DocumentCryptoProvider,
    documentCache: DocumentCache,
    isFileAvailableLocally: @escaping (Attachment) throws -> Bool
  ) throws {
    self.attachment = attachment
    self.progress = progress
    self.documentCache = documentCache
    self.downloadedFileURL = try documentCache.urlOfEncryptedDirectory(with: attachment.id)
    self.decryptedFileURL = try documentCache.urlOfDecryptedDirectory(with: attachment.id)
    self.userDeviceAPIClient = userDeviceAPIClient
    self.cryptoProvider = cryptoProvider
    self.isFileAvailableLocally = isFileAvailableLocally
  }

  private func indicateBackgroundTaskEnd() {
    if let backgroundActivity = backgroundActivity {
      ProcessInfo.processInfo.endActivity(backgroundActivity)
    }
  }

  private lazy var urlSession: URLSession = {
    let configuration = URLSessionConfiguration.ephemeral
    return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
  }()

  public func requestDownload() async throws -> URL {
    self.backgroundActivity = ProcessInfo.processInfo.beginActivity(
      options: [.userInitiated], reason: "DocumentDownload")
    if try isFileAvailableLocally(attachment) {
      let url = try await decryptFile()
      indicateBackgroundTaskEnd()
      progress?.cancel()
      return url
    } else {
      let response = try await userDeviceAPIClient.securefile.getDownloadLink(
        key: attachment.downloadKey)
      guard let link = URL(string: response.url) else {
        throw DocumentDownloadError("Document download url is not a valid URL")
      }
      return try await self.download(from: link)
    }
  }

  private func decryptFile() async throws -> URL {
    try await Task.detached { [decryptedFileURL, downloadedFileURL, attachment, cryptoProvider] in
      guard let cryptoKey = Data(base64Encoded: attachment.cryptoKey) else {
        throw DocumentDownloadError("cryptoKey is not base64 string")
      }

      let cryptoEngine = try cryptoProvider.fileCryptoEngine(for: cryptoKey)
      try cryptoEngine.decrypt(downloadedFileURL, to: decryptedFileURL)
    }.value

    return decryptedFileURL
  }

  private func download(from downloadLink: URL) async throws -> URL {
    try await withCheckedThrowingContinuation { continuation in
      let downloadTask = self.urlSession.downloadTask(with: downloadLink) {
        [weak self] url, _, error in
        guard let self = self else { return }
        if let error = error {
          continuation.resume(throwing: error)
        } else if let url = url {
          do {
            let downloadedFilesize = Int(try FileInformation.size(ofFile: url))
            guard self.attachment.remoteSize == downloadedFilesize else {
              continuation.resume(
                throwing: DocumentDownloadError("Remote file is an unexpected size"))
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
    self.indicateBackgroundTaskEnd()
  }
}

extension DocumentDownload: URLSessionDelegate {
  public func urlSession(
    _ session: URLSession, didReceive challenge: URLAuthenticationChallenge,
    completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Swift.Void
  ) {
    completionHandler(.performDefaultHandling, nil)
  }
}
