import Foundation
import CorePersonalData
import Combine
import CoreUserTracking
import DashlaneAppKit
import DocumentServices
import UIDelight
import PDFKit
import VaultKit
import DashTypes
import SwiftUI

class AttachmentsListViewModel: SessionServicesInjecting, ObservableObject, MockVaultConnectedInjecting {

    @Published
    var editingItem: VaultItem

    @Published
    var attachments: [Attachment] = []

    let addAttachmentButtonViewModel: AddAttachmentButtonViewModel
    private let documentStorageService: DocumentStorageService
    private let activityReporter: ActivityReporterProtocol
    private let usageLogService: UsageLogServiceProtocol
    private var subscriptions = Set<AnyCancellable>()
    private let logger: AttachmentsListUsageLogger
    private let impactGenerator = UserFeedbackGenerator.makeImpactGenerator()
    private let database: ApplicationDatabase

    init(documentStorageService: DocumentStorageService,
         usageLogService: UsageLogServiceProtocol,
         activityReporter: ActivityReporterProtocol,
         database: ApplicationDatabase,
         editingItem: VaultItem,
         makeAddAttachmentButtonViewModel: AddAttachmentButtonViewModel.Factory,
         itemPublisher: AnyPublisher<VaultItem, Never>) {
        self.usageLogService = usageLogService
        self.documentStorageService = documentStorageService
        self.activityReporter = activityReporter
        self.database = database
        self.editingItem = editingItem
        self.logger = AttachmentsListUsageLogger(anonId: editingItem.anonId, usageLogService: usageLogService)
        self.addAttachmentButtonViewModel = makeAddAttachmentButtonViewModel.make(editingItem: editingItem,
                                                                                  logger: logger,
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
            .map { item, uploads -> [Attachment] in
                let existingDocuments = item.attachments ?? []
                let result = existingDocuments + uploads
                return result.sorted { $0.creationDatetime < $1.creationDatetime }
            }
            .assign(to: &$attachments)
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

    func rowViewModel(_ attachment: Attachment) -> AttachmentRowViewModel {
        let attachmentPublisher = $editingItem
            .compactMap {
                $0.attachments?.filter {  $0.id == attachment.id }.first ?? nil
            }
            .eraseToAnyPublisher()
        return .init(attachment: attachment,
                     attachmentPublisher: attachmentPublisher,
                     editingItem: editingItem,
                     database: database,
                     usageLogService: usageLogService,
                     documentStorageService: documentStorageService,
                     deleteAction: self.delete(_:))
    }

    func delete(_ attachment: Attachment) {
        Task {
            do {
                try await self.documentStorageService
                    .documentDeleteService
                    .deleteAttachment(attachment, on: self.editingItem)
                self.logger.logDeleteConfirm()
                self.logUpdateAction(.delete)
            } catch {
                print(error)
            }
        }
    }
}

extension AttachmentsListViewModel {
    private static var item: SecureNote {
        SecureNote()
    }

    static var mock: AttachmentsListViewModel {
        .init(documentStorageService: DocumentStorageService.mock,
              usageLogService: UsageLogService.fakeService,
              activityReporter: .fake,
              database: ApplicationDBStack.mock(),
              editingItem: item,
              makeAddAttachmentButtonViewModel: .init { _, _, _, _   in AddAttachmentButtonViewModel.mock },
              itemPublisher: Just(item).eraseToAnyPublisher())
    }
}
