import Foundation
import SwiftUI
import DocumentServices
import CoreUserTracking
import VaultKit
import UIDelight
import Combine
import PDFKit
import CorePersonalData
import CoreFeature

enum AttachmentError: Error {
    case incorrectName

    var description: String {
        switch self {
        case .incorrectName:
            return "Incorrect name"
        }
    }
}

class AddAttachmentButtonViewModel: ObservableObject, SessionServicesInjecting, MockVaultConnectedInjecting {

    enum File {
        case document(fileUrl: URL)
        case fileData(FileData, filename: String)
    }

    enum FileData: Identifiable {
        var id: String {
            switch self {
            case .scan:
                return "scan"
            case .image:
                return "image"
            }
        }

        case scan(data: Data)
        case image(ImagePicker.ImageData)
    }

    enum AddAttachmentPermission {
        case allowed
        case notAllowedNeedsToUpgradePlan
        case notAllowedItemIsShared
    }

    @Published
    var imageContent: ImagePicker.ImageData?

    @Published
    var fileUrl: URL?

    @Published
    var error: Error?

    @Published
    var editingItem: VaultItem

    private var fileData: FileData? {
        didSet {
            self.filename = fileData?.defaultName ?? ""
        }
    }

    @Published
    var filename: String = ""

    @Published
    var showRenameFile: Bool = false

    let addAttachmentPermission: AddAttachmentPermission
    private let documentStorageService: DocumentStorageService
    private let premiumService: PremiumServiceProtocol
    private let featureService: FeatureServiceProtocol
    private let activityReporter: ActivityReporterProtocol
    private let impactGenerator = UserFeedbackGenerator.makeImpactGenerator()
    private let logger: AttachmentsListUsageLogger
    private var subscriptions = Set<AnyCancellable>()

            let shouldDisplayRenameAlert: Bool

    private var isRenamingFileEnabled: Bool {
        shouldDisplayRenameAlert && featureService.isEnabled(.documentStorageAllItems)
    }

    init(documentStorageService: DocumentStorageService,
         activityReporter: ActivityReporterProtocol,
         featureService: FeatureServiceProtocol,
         editingItem: VaultItem,
         premiumService: PremiumServiceProtocol,
         logger: AttachmentsListUsageLogger,
         shouldDisplayRenameAlert: Bool = true,
         itemPublisher: AnyPublisher<VaultItem, Never>) {
        self.documentStorageService = documentStorageService
        self.activityReporter = activityReporter
        self.featureService = featureService
        self.editingItem = editingItem
        self.shouldDisplayRenameAlert = shouldDisplayRenameAlert
        self.premiumService = premiumService
        self.logger = logger
        if !premiumService.hasSecureFilesCapability {
            self.addAttachmentPermission = .notAllowedNeedsToUpgradePlan
        } else if editingItem.isShared {
            self.addAttachmentPermission = .notAllowedItemIsShared
        } else {
            self.addAttachmentPermission = .allowed
        }

        $imageContent
            .sink { imageContent in
                guard let imageContent = imageContent else { return }
                if self.isRenamingFileEnabled {
                    self.fileData = .image(imageContent)
                    self.showRenameFile = true
                } else {
                    self.save(.fileData(.image(imageContent), filename: L10n.Localizable.kwDefaultFilename + ".jpeg"))
                }
            }
            .store(in: &subscriptions)

        $fileUrl
            .sink { url in
                guard let url = url else { return }
                self.save(.document(fileUrl: url))
            }
            .store(in: &subscriptions)

        itemPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: &$editingItem)
    }

    func saveScanImagesIntoPDF(result: Result<[UIImage], Error>) {
        switch result {
        case let .failure(error):
            self.error = error
        case let .success(images):
            guard images.count > 0 else { return }

                        let pdfDocument = PDFDocument()
            images.enumerated().forEach { index, image in
                if let pdfPage = PDFPage(image: image) {
                    pdfDocument.insert(pdfPage, at: index)
                }
            }
            guard let data = pdfDocument.dataRepresentation() else { return }

            if self.isRenamingFileEnabled {
                self.fileData = .scan(data: data)
                self.showRenameFile = true
            } else {
                save(.fileData(.scan(data: data), filename: L10n.Localizable.scannedDocumentName + ".pdf"))
            }
        }
    }

    private func save(_ file: File) {
        do {
            try performSave(file)
        } catch {
            self.error = error
        }
    }

    private func performSave(_ file: File) throws {
        switch file {
        case let .document(fileUrl):
                        let movedUrl = try self.documentStorageService.documentCache.move(fileUrl,
                                                                              to: .decryptedDirectory,
                                                                              filename: fileUrl.lastPathComponent,
                                                                              isUnique: true)
            try self.upload(movedUrl)
        case let .fileData(fileData, filename):
            switch fileData {
            case let .image(imageData):
                if let url = imageData.fileUrl {
                                        let movedUrl = try self.documentStorageService.documentCache.copy(url,
                                                                                      to: .decryptedDirectory,
                                                                                      filename: filename.imageNameWithExtension,
                                                                                      isUnique: true)
                    try self.upload(movedUrl)
                } else {
                                        let image = imageData.image
                    let url = try documentStorageService.documentCache.write(image,
                                                                             to: .decryptedDirectory,
                                                                             filename: filename.imageNameWithExtension,
                                                                             isUnique: true)
                    try self.upload(url)
                }
            case let .scan(data):
                let fileUrl = try documentStorageService.documentCache.write(data,
                                                                             to: .decryptedDirectory,
                                                                             filename: filename.pdfDocumentWithExtension,
                                                                             isUnique: true)
                try self.upload(fileUrl)
            }
        }
    }

    private func upload(_ fileURL: URL) throws {
        let progress = Progress(totalUnitCount: 1)
        Task.detached { [weak self] in
            guard let self = self else { return }
            do {
                try await self.documentStorageService.upload(fileURL,
                                                             progress: progress,
                                                             item: { self.editingItem },
                                                             tag: self.editingItem.id.rawValue)
                self.logger.logUploadSuccess()
                self.logUpdateAction(.add)
                self.impactGenerator?.impactOccurred()
            } catch {
                self.error = error
                self.logger.logUploadError()
            }
        }
    }

    func logView() {
        activityReporter.report(UserEvent.ViewVaultItemAttachment(itemId: editingItem.userTrackingLogID,
                                                                  itemType: editingItem.logItemType))
    }

    func logUpdateAction(_ action: Definition.Action) {
        activityReporter.report(UserEvent.UpdateVaultItemAttachment(attachmentAction: action,
                                                                    itemId: editingItem.userTrackingLogID,
                                                                    itemType: editingItem.logItemType))
    }

    func saveNewFile(with fileName: String) {
        let trimmedFileName = fileName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let fileData = fileData else { return }
        guard !filename.isEmpty else {
            self.error = AttachmentError.incorrectName
            return
        }
        switch fileData {
        case let .scan(data):
            self.save(.fileData(.scan(data: data), filename: trimmedFileName))
        case let .image(imageData):
            self.save(.fileData(.image(imageData), filename: trimmedFileName))
        }
    }
}

private extension PremiumServiceProtocol {
    var hasSecureFilesCapability: Bool {
        return status?.capabilities.secureFiles.enabled ?? false
    }
}

extension AddAttachmentButtonViewModel {
    private static var item: SecureNote {
        SecureNote()
    }

    static var mock: AddAttachmentButtonViewModel {
        .init(documentStorageService: DocumentStorageService.mock,
              activityReporter: .fake,
              featureService: .mock(),
              editingItem: Credential(),
              premiumService: PremiumServiceMock(),
              logger: AttachmentsListUsageLogger(anonId: "", usageLogService: UsageLogService.fakeService),
              itemPublisher: Just(item).eraseToAnyPublisher())
    }
}

extension VaultItem {
    var logItemType: Definition.ItemType {
        switch self.enumerated {
        case .address: return .address
        case .bankAccount: return .bankStatement
        case .company: return .company
        case .credential: return .credential
        case .creditCard: return .creditCard
        case .drivingLicence: return .driverLicence
        case .secureNote: return .secureNote
        case .identity: return .identity
        case .email: return .email
        case .phone: return .phone
        case .personalWebsite: return .website
        case .passport: return .passport
        case .idCard: return .idCard
        case .fiscalInformation: return .fiscalStatement
        case .socialSecurityInformation: return .socialSecurity
        }
    }
}

private extension AddAttachmentButtonViewModel.FileData {
    var defaultName: String {
        switch self {
        case .scan:
            return L10n.Localizable.scannedDocumentName + ".pdf"
        case .image:
            return L10n.Localizable.kwDefaultFilename + ".jpeg"
        }
    }
}

private extension String {
    var imageNameWithExtension: String {
        let filename = NSString(string: self)
        let pathExtention = filename.pathExtension
        let pathPrefix = filename.deletingPathExtension
        return pathPrefix + ".jpeg"
    }

    var pdfDocumentWithExtension: String {
        let filename = NSString(string: self)
        let pathExtention = filename.pathExtension
        let pathPrefix = filename.deletingPathExtension
        return pathPrefix + ".pdf"
    }
}
