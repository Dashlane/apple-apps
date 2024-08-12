#if canImport(UIKit)
  import Foundation
  import DocumentServices
  import CorePersonalData
  import CoreMedia
  import QuickLook
  import Combine
  import UIDelight
  import DashTypes

  public class AttachmentRowViewModel: ObservableObject, VaultKitServicesInjecting {
    enum State: Equatable, Hashable {
      enum LoadingType {
        case upload
        case download
      }

      var isLoading: Bool {
        switch self {
        case .loading: return true
        default: return false
        }
      }

      case idle
      case loading(progress: Progress, type: LoadingType)
      case downloaded
    }

    @Published
    var state: State = .idle

    @Published
    var progress: Double?

    @Published
    var filename: String = ""

    @Published
    var attachment: Attachment

    @Published
    var error: String?

    private let documentStorageService: DocumentStorageService
    private let database: ApplicationDatabase
    private let deleteAction: (Attachment) -> Void
    let editingItem: DocumentAttachable
    var previewDataSource: PreviewDataSource?

    private var subscriptions = Set<AnyCancellable>()
    private let impactGenerator = UserFeedbackGenerator.makeImpactGenerator()

    var creationDate: String {
      AttachmentRowViewModel
        .fileDateFormat
        .string(from: Date(timeIntervalSince1970: Double(attachment.creationDatetime)))
    }

    fileprivate static var fileDateFormat: DateFormatter {
      let dateFormatter = DateFormatter()
      dateFormatter.dateStyle = .long
      dateFormatter.timeStyle = .short
      return dateFormatter
    }

    public init(
      attachment: Attachment,
      attachmentPublisher: AnyPublisher<Attachment, Never>,
      editingItem: DocumentAttachable,
      database: ApplicationDatabase,
      documentStorageService: DocumentStorageService,
      deleteAction: @escaping (Attachment) -> Void
    ) {
      self.attachment = attachment
      self.deleteAction = deleteAction
      self.documentStorageService = documentStorageService
      self.database = database
      self.editingItem = editingItem
      self.filename = attachment.filename
      setupPublishers()
      attachmentPublisher
        .assign(to: &$attachment)
    }

    func setupPublishers() {
      documentStorageService.$uploads
        .combineLatest(documentStorageService.$downloads)
        .map { [attachment, documentStorageService] uploads, downloads -> State in
          if let progress = uploads.progress(for: attachment) {
            return .loading(progress: progress, type: .upload)
          } else if let progress = downloads.progress(for: attachment) {
            return .loading(progress: progress, type: .download)
          } else if (try? documentStorageService.isFileAvailableLocally(for: attachment)) ?? false {
            return .downloaded
          } else {
            return .idle
          }
        }
        .receive(on: DispatchQueue.main)
        .assign(to: &$state)

      $state.map { state -> AnyPublisher<Double?, Never> in
        if case let .loading(progress, _) = state {
          return
            progress
            .publisher(for: \.fractionCompleted)
            .map { $0 as Double? }
            .eraseToAnyPublisher()
        } else {
          return Just<Double?>(nil).eraseToAnyPublisher()
        }
      }
      .switchToLatest()
      .receive(on: DispatchQueue.main)
      .assign(to: \.progress, on: self)
      .store(in: &subscriptions)
    }

    func download() async throws -> URL {
      let progress = Progress(totalUnitCount: 1)
      do {
        let url = try await documentStorageService.download(attachment, progress: progress)
        await MainActor.run {
          self.impactGenerator.impactOccurred()
          self.state = .downloaded
        }
        return url
      } catch {
        await MainActor.run {
          self.state = .idle
          self.error = error.localizedDescription
        }
        throw error
      }
    }

    func getDownloadedFileURL() async throws -> URL {
      let url = try await documentStorageService.download(attachment)
      return try self.documentStorageService.documentCache.move(
        url,
        to: .decryptedDirectory,
        filename: self.attachment.filename,
        isUnique: true)
    }

    func renameAttachment() {
      guard !self.filename.pathPrefixIsEmpty else {
        self.filename = attachment.filename
        self.error = AttachmentError.incorrectName.localizedDescription
        return
      }
      var temp = attachment
      let oldExtension = attachment.filename.fileExtension
      let newFileName = self.filename
        .trimmingCharacters(in: .whitespacesAndNewlines)
        .replaceExtension(with: oldExtension)
      temp.filename = newFileName
      do {
        var item = editingItem
        item.updateAttachments(with: temp)
        try database.update(item)
        self.attachment = temp

        if var secureFileInfo = try database.fetch(
          with: .init(temp.id), type: SecureFileInformation.self)
        {
          secureFileInfo.filename = newFileName
          try database.save(secureFileInfo)
        }
        self.filename = newFileName
      } catch {
        self.error = error.localizedDescription
      }
    }

    func delete() {
      self.deleteAction(self.attachment)
    }
  }

  extension Sequence where Element == DocumentUpload {
    fileprivate func progress(for attachment: Attachment) -> Progress? {
      first { $0.secureFileInfo.id.rawValue == attachment.id }?.progress
    }
  }

  extension Sequence where Element == DocumentDownload {
    fileprivate func progress(for attachment: Attachment) -> Progress? {
      first { $0.attachment.id == attachment.id }?.progress
    }
  }

  extension AttachmentRowViewModel {
    private static var mockAttachment: Attachment {
      .init(
        id: UUID().uuidString,
        version: 1,
        type: "jpg",
        filename: "myFile",
        downloadKey: "",
        cryptoKey: "",
        localSize: 0,
        remoteSize: 0,
        creationDatetime: Date().dateTime,
        userModificationDatetime: Date().dateTime,
        owner: "rayane")
    }

    static var mock: AttachmentRowViewModel {
      .init(
        attachment: mockAttachment,
        attachmentPublisher: Just<Attachment>(mockAttachment).eraseToAnyPublisher(),
        editingItem: SecureNote(),
        database: ApplicationDBStack.mock(),
        documentStorageService: DocumentStorageService.mock, deleteAction: { _ in })
    }
  }

  extension Date {
    fileprivate var dateTime: UInt64 {
      return UInt64(timeIntervalSince1970)
    }
  }

  class PreviewDataSource: QLPreviewControllerDataSource {
    let url: URL

    init(url: URL) {
      self.url = url
    }

    func numberOfPreviewItems(in controller: QLPreviewController) -> Int { 1 }
    func previewController(_ controller: QLPreviewController, previewItemAt index: Int)
      -> QLPreviewItem
    {
      return url as QLPreviewItem
    }
  }

  extension String {
    fileprivate var fileExtension: String {
      let nsString = NSString(string: self)
      return nsString.pathExtension
    }

    fileprivate var pathPrefixIsEmpty: Bool {
      guard !isEmpty else { return true }
      let pathPrefix = NSString(string: self).deletingPathExtension
      return pathPrefix.isEmpty
    }

    fileprivate func replaceExtension(with newExtension: String) -> String {
      let pathPrefix = NSString(string: self).deletingPathExtension
      return "\(pathPrefix).\(newExtension)"
    }
  }
#endif
