import Combine
import CorePersonalData
import CoreTypes
import DocumentServices
import Foundation
import PDFKit
import SwiftTreats
import SwiftUI
import UIDelight
import UserTrackingFoundation

public class AttachmentsListViewModel: ObservableObject, VaultKitServicesInjecting {

  @Published
  var editingItem: VaultItem

  @Published
  var attachments: [Attachment] = []

  @Published var showRenameDocument: Bool = false
  @Published var selectedAttachment: Attachment?
  @Published var newAttachmentName: String = ""
  @Published var showDeleteConfirmation: Bool = false
  @Published var showQuickLookPreview: Bool = false
  @Published var error: String?
  @Published var exportURLMac: URL?
  var previewDataSource: PreviewDataSource?

  let addAttachmentButtonViewModel: AddAttachmentButtonViewModel
  private let documentStorageService: DocumentStorageService
  private let activityReporter: ActivityReporterProtocol
  private var subscriptions = Set<AnyCancellable>()
  private let impactGenerator = UserFeedbackGenerator.makeImpactGenerator()
  private let database: ApplicationDatabase

  public init(
    documentStorageService: DocumentStorageService,
    activityReporter: ActivityReporterProtocol,
    database: ApplicationDatabase,
    editingItem: VaultItem,
    makeAddAttachmentButtonViewModel: AddAttachmentButtonViewModel.Factory,
    itemPublisher: AnyPublisher<VaultItem, Never>
  ) {
    self.documentStorageService = documentStorageService
    self.activityReporter = activityReporter
    self.database = database
    self.editingItem = editingItem
    self.addAttachmentButtonViewModel = makeAddAttachmentButtonViewModel.make(
      editingItem: editingItem,
      itemPublisher: itemPublisher)

    itemPublisher
      .receive(on: DispatchQueue.main)
      .assign(to: &$editingItem)

    let uploadingDocumentsPublisher = documentStorageService.$uploads
      .map { uploads -> [Attachment] in
        uploads
          .filter { $0.item().id == self.editingItem.id }
          .compactMap { try? Attachment(from: $0.secureFileInfo) }
      }
      .eraseToAnyPublisher()

    itemPublisher
      .combineLatest(uploadingDocumentsPublisher)
      .debounce(for: 0.2, scheduler: DispatchQueue.main)
      .map { item, uploads -> [Attachment] in
        let existingDocuments = item.attachments ?? []
        let result = existingDocuments + uploads
        return result.sorted { $0.creationDatetime < $1.creationDatetime }
      }
      .assign(to: &$attachments)
  }

  func logView() {
    let editingItem = editingItem
    activityReporter.report(
      UserEvent.ViewVaultItemAttachment(
        itemId: editingItem.userTrackingLogID,
        itemType: editingItem.logItemType))
  }

  func logUpdateAction(_ action: Definition.Action) {
    let editingItem = editingItem
    activityReporter.report(
      UserEvent.UpdateVaultItemAttachment(
        attachmentAction: action,
        itemId: editingItem.userTrackingLogID,
        itemType: editingItem.logItemType))
  }

  func rowViewModel(_ attachment: Attachment) -> AttachmentRowViewModel {
    let fileNamePublisher =
      $editingItem
      .compactMap {
        $0.attachments?.filter { $0.id == attachment.id }.first?.filename ?? nil
      }
      .eraseToAnyPublisher()
    return .init(
      id: attachment.id,
      name: attachment.filename,
      fileNamePublisher: fileNamePublisher,
      creationDate: attachment.creationDatetime,
      fileSize: attachment.localSize,
      state: documentStorageService.state(for: attachment),
      userAction: { action in
        switch action {
        case .delete:
          self.showDeleteDialog(attachment)
        case .rename:
          self.showRenameDialog(attachment)
        case .preview:
          Task {
            await self.presentQuickLookPreview(attachment)
          }
        case .download:
          Task.detached {
            await self.download(attachment)
          }
        }
      })
  }

  func showDeleteDialog(_ attachment: Attachment) {
    selectedAttachment = attachment
    showDeleteConfirmation = true
  }

  func delete(_ attachment: Attachment) {
    Task {
      do {
        try await self.documentStorageService
          .documentUpdateService
          .deleteAttachment(attachment, on: self.editingItem)
        self.logUpdateAction(.delete)
      } catch {
        print(error)
      }
    }
  }

  func download(_ attachment: Attachment) async {
    let progress = Progress(totalUnitCount: 1)
    do {
      let url = try await documentStorageService.download(attachment, progress: progress)

      await MainActor.run {
        if Device.is(.mac) {
          exportURLMac = url
        }
        self.impactGenerator.impactOccurred()
      }

    } catch {
      await MainActor.run {
        self.error = error.localizedDescription
      }
    }
  }

  func showRenameDialog(_ attachment: Attachment) {
    selectedAttachment = attachment
    newAttachmentName = attachment.filename
    showRenameDocument = true
  }

  func renameAttachment() async {
    guard let attachment = selectedAttachment else { return }
    guard !self.newAttachmentName.pathPrefixIsEmpty else {
      self.error = AttachmentError.incorrectName.localizedDescription
      return
    }
    let oldExtension = attachment.filename.fileExtension
    let newFileName = self.newAttachmentName
      .trimmingCharacters(in: .whitespacesAndNewlines)
      .replaceExtension(with: oldExtension)
    do {
      try await self.rename(attachment, withName: newFileName)
    } catch {
      self.error = error.localizedDescription
    }
  }

  private func rename(_ attachment: Attachment, withName newFileName: String) async throws {
    try await self.documentStorageService
      .documentUpdateService
      .renameAttachment(attachment, withName: newFileName, on: self.editingItem)
    self.logUpdateAction(.edit)
  }

  @MainActor
  private func presentQuickLookPreview(_ attachment: Attachment) async {
    do {
      let url = try await documentStorageService.download(attachment)
      let fileURL = try self.documentStorageService.documentCache.move(
        url,
        to: .decryptedDirectory,
        filename: attachment.filename,
        isUnique: true)
      #if targetEnvironment(macCatalyst)
        await UIApplication.shared.open(fileURL)
      #else
        previewDataSource = PreviewDataSource(url: fileURL)
        showQuickLookPreview = true
      #endif
    } catch {}
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

extension AttachmentsListViewModel {
  private static var item: SecureNote {
    SecureNote()
  }

  static var mock: AttachmentsListViewModel {
    .init(
      documentStorageService: DocumentStorageService.mock,
      activityReporter: .mock,
      database: ApplicationDBStack.mock(),
      editingItem: item,
      makeAddAttachmentButtonViewModel: .init { _, _, _ in AddAttachmentButtonViewModel.mock },
      itemPublisher: Just(item).eraseToAnyPublisher())
  }
}

extension DocumentStorageService {
  func state(for attachment: Attachment) -> AnyPublisher<AttachmentState, Never> {
    $uploads
      .combineLatest($downloads)
      .map { [attachment, self] uploads, downloads -> AttachmentState in
        if let progress = uploads.attachmentProgress(withId: attachment.id) {
          return .loading(progress: progress, type: .upload)
        } else if let progress = downloads.attachmentProgress(withId: attachment.id) {
          return .loading(progress: progress, type: .download)
        } else if (try? isFileAvailableLocally(for: attachment)) ?? false {
          return .downloaded
        } else {
          return .idle
        }
      }
      .receive(on: DispatchQueue.main)
      .eraseToAnyPublisher()
  }
}

extension Sequence where Element == DocumentUpload {
  fileprivate func attachmentProgress(withId id: String) -> Progress? {
    first { $0.secureFileInfo.id.rawValue == id }?.progress
  }
}

extension Sequence where Element == DocumentDownload {
  fileprivate func attachmentProgress(withId id: String) -> Progress? {
    first { $0.attachment.id == id }?.progress
  }
}
