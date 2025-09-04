import Combine
import CoreNetworking
import CorePersonalData
import CoreTypes
import DashlaneAPI
import Foundation
import SwiftUI

public final class DocumentStorageService {
  @Published
  public var uploads: [DocumentUpload] = []

  @Published
  public private(set) var downloads: [DocumentDownload] = []

  public let documentCache: DocumentCache = DocumentCache()
  public let documentUpdateService: DocumentUpdateService
  let database: ApplicationDatabase
  let userDeviceAPIClient: UserDeviceAPIClient
  let cryptoProvider: DocumentCryptoProvider

  let login: Login
  var autoClearCacheSubscription: AnyCancellable?
  let lockedPublisher: AnyPublisher<Void, Never>

  public init(
    database: ApplicationDatabase,
    userDeviceAPIClient: UserDeviceAPIClient,
    cryptoProvider: DocumentCryptoProvider,
    lockedPublisher: AnyPublisher<Void, Never>,
    login: Login
  ) {
    self.database = database
    self.userDeviceAPIClient = userDeviceAPIClient
    self.cryptoProvider = cryptoProvider
    self.documentUpdateService = DocumentUpdateService(
      database: database,
      userDeviceAPIClient: userDeviceAPIClient)
    self.login = login
    self.lockedPublisher = lockedPublisher
    setupClearingCache()
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

  private func setupClearingCache() {
    let closingPublisher = NotificationCenter.default
      .publisher(for: UIApplication.willTerminateNotification)
      .map { _ in return Void() }

    autoClearCacheSubscription =
      lockedPublisher
      .merge(with: closingPublisher)
      .sink { [weak self] in
        self?.clearCache()
      }
  }

  private func clearCache() {
    try? self.documentCache.clear(.decryptedDirectory)
  }
}

extension DocumentStorageService {
  public func upload(
    _ fileURL: URL,
    progress: Progress,
    item: @escaping () -> DocumentAttachable,
    tag: String
  ) async throws {
    let documentUpload = try DocumentUpload(
      url: fileURL,
      email: login.email,
      item: item,
      progress: progress,
      tag: tag,
      cryptoProvider: cryptoProvider,
      database: database,
      documentCache: documentCache,
      userDeviceAPIClient: userDeviceAPIClient)
    try await documentUpload.encryptFile()
    add(documentUpload)
    defer {
      self.removeCompletedUpload(with: tag)
    }
    try await documentUpload.requestUpload()
  }

  public func download(_ attachment: Attachment, progress: Progress? = nil) async throws -> URL {
    let documentDownload = try DocumentDownload(
      attachment,
      progress: progress,
      userDeviceAPIClient: userDeviceAPIClient,
      cryptoProvider: cryptoProvider,
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

  public func isFileAvailableLocally(for attachment: Attachment) throws -> Bool {
    guard let downloadedFileURL = try? documentCache.urlOfEncryptedDirectory(with: attachment.id)
    else {
      return false
    }
    guard let size = try? FileInformation.size(ofFile: downloadedFileURL) else {
      return false
    }
    guard attachment.remoteSize == size else {
      throw DocumentDownloadError(
        "Actual filesize \(size) does not match value defined in Attachment \(attachment.remoteSize)"
      )
    }
    return true
  }

  public func fileURL(for attachment: Attachment) throws -> URL? {
    guard let downloadedFileURL = try? documentCache.urlOfEncryptedDirectory(with: attachment.id)
    else {
      return nil
    }
    guard let size = try? FileInformation.size(ofFile: downloadedFileURL) else {
      return nil
    }
    guard attachment.remoteSize == size else {
      throw DocumentDownloadError(
        "Actual filesize \(size) does not match value defined in Attachment \(attachment.remoteSize)"
      )
    }
    return downloadedFileURL
  }
}

extension DocumentStorageService {
  public static var mock: DocumentStorageService {
    .init(
      database: ApplicationDBStack.mock(),
      userDeviceAPIClient: .mock({}),
      cryptoProvider: .mock(),
      lockedPublisher: Combine.Empty().eraseToAnyPublisher(),
      login: .init("_"))
  }
}
