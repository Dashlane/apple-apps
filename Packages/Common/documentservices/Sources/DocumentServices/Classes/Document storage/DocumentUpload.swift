import CoreNetworking
import CorePersonalData
import CyrilKit
import DashTypes
import DashlaneAPI
import Foundation

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

  private let userDeviceAPIClient: UserDeviceAPIClient

  private var cryptoProvider: DocumentCryptoProvider

  public private(set) var progress: Progress

  let id = UUID().uuidString

  public let tag: String

  private(set) var isFinished: Bool = false

  private var backgroundActivity: NSObjectProtocol?

  private var task: URLSessionTask?

  private let documentCache: DocumentCache
  private let database: ApplicationDatabase

  init(
    url: URL,
    email: String,
    item: @escaping () -> DocumentAttachable,
    progress: Progress,
    tag: String = "unknown",
    cryptoProvider: DocumentCryptoProvider,
    database: ApplicationDatabase,
    documentCache: DocumentCache,
    userDeviceAPIClient: UserDeviceAPIClient
  ) throws {
    self.tag = tag
    self.progress = progress
    self.item = item
    self.plaintextUrl = url
    self.userDeviceAPIClient = userDeviceAPIClient
    self.documentCache = documentCache
    self.database = database
    self.cryptoProvider = cryptoProvider
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

  private func indicateBackgroundTaskEnd() {
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
      self.indicateBackgroundTaskEnd()
      throw error
    }
  }

  func encryptFile() async throws {
    let backgroundActivity = ProcessInfo.processInfo.beginActivity(
      options: [.userInitiated], reason: "DocumentUpload")
    self.backgroundActivity = backgroundActivity

    let cryptoKey = try await Task.detached { [cryptoProvider, plaintextUrl, encryptedUrl] in
      let cryptoKey = Data.random(ofSize: 32)
      let cryptoEngine = try cryptoProvider.fileCryptoEngine(for: cryptoKey)
      try cryptoEngine.encrypt(plaintextUrl, to: encryptedUrl)
      return cryptoKey
    }.value

    self.secureFileInfo.cryptoKey = cryptoKey.base64EncodedString()

    let remoteFileSize = try FileInformation.size(ofFile: self.encryptedUrl)
    self.secureFileInfo.remoteSize = "\(remoteFileSize)"
  }
}

extension DocumentUpload {

  private func getUploadLink() async throws -> UserDeviceAPIClient.Securefile.GetUploadLink.Response
  {
    guard let remoteSize = Int(secureFileInfo.remoteSize) else {
      throw DocumentUploadError(
        "Remote size should be already set at this point. If not, encryption may have failed")
    }
    return try await userDeviceAPIClient.securefile.getUploadLink(
      contentLength: remoteSize, secureFileInfoId: secureFileInfo.id.rawValue)
  }

  private func upload(with authentication: UserDeviceAPIClient.Securefile.GetUploadLink.Response)
    async throws
  {
    self.secureFileInfo.downloadKey = authentication.key
    let urlsessionUploader = FileUploader()
    try await urlsessionUploader.uploadFile(
      at: encryptedUrl, with: authentication, progress: self.progress)
  }

  private func commitFile() async throws {
    _ = try await userDeviceAPIClient.securefile.commitSecureFile(
      key: secureFileInfo.downloadKey, secureFileInfoId: secureFileInfo.id.rawValue)
    self.isFinished = true
    var editingItem = self.item()
    try editingItem.updateAttachments(with: self.secureFileInfo)
    try self.database.update(editingItem)
    _ = try self.database.save(self.secureFileInfo)
    try FileManager.default.removeItem(at: self.plaintextUrl)
    self.indicateBackgroundTaskEnd()
  }
}
