import Foundation
import CorePersonalData
import VaultKit
import Combine
import DocumentServices

class AttachmentsSectionViewModel: ObservableObject, SessionServicesInjecting, MockVaultConnectedInjecting {

    @Published
    var item: VaultItem

    @Published
    var progress: Double?

    private let itemPublisher: AnyPublisher<VaultItem, Never>
    let addAttachmentButtonViewModel: AddAttachmentButtonViewModel
    private let attachmentsListViewModelProvider: (VaultItem, AnyPublisher<VaultItem, Never>) -> AttachmentsListViewModel
    private let vaultItemsService: VaultItemsServiceProtocol
    private let documentStorageService: DocumentStorageService
    private let logger: AttachmentsListUsageLogger
    private var subscriptions = Set<AnyCancellable>()

    init(vaultItemsService: VaultItemsServiceProtocol,
         item: VaultItem,
         usageLogService: UsageLogServiceProtocol,
         documentStorageService: DocumentStorageService,
         attachmentsListViewModelProvider: @escaping (VaultItem, AnyPublisher<VaultItem, Never>) -> AttachmentsListViewModel,
         makeAddAttachmentButtonViewModel: AddAttachmentButtonViewModel.Factory,
         itemPublisher: AnyPublisher<VaultItem, Never>) {
        self.vaultItemsService = vaultItemsService
        self.documentStorageService = documentStorageService
        self.attachmentsListViewModelProvider = attachmentsListViewModelProvider
        self.itemPublisher = itemPublisher
        self.item = item
        self.logger = AttachmentsListUsageLogger(anonId: item.anonId, usageLogService: usageLogService)
        self.addAttachmentButtonViewModel = makeAddAttachmentButtonViewModel.make(editingItem: item,
                                                                                  logger: logger,
                                                                                  shouldDisplayRenameAlert: false,
                                                                                  itemPublisher: itemPublisher)
        itemPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: &$item)

        documentStorageService.$uploads
            .map { uploads -> Progress? in
                uploads
                    .first { $0.item().id == self.item.id }
                    .flatMap(\.progress)
            }
            .map { progress -> AnyPublisher<Double?, Never> in
                guard let progress = progress else { return Just(nil).eraseToAnyPublisher() }
                return progress
                    .publisher(for: \.fractionCompleted)
                    .map { $0 as Double? }
                    .eraseToAnyPublisher()
            }
            .switchToLatest()
            .receive(on: DispatchQueue.main)
            .assign(to: &$progress)
    }

    func makeAttachmentsListViewModel() -> AttachmentsListViewModel? {
        return attachmentsListViewModelProvider(item, itemPublisher)
    }
}

extension AttachmentsSectionViewModel {
    private static var item: SecureNote {
        SecureNote()
    }

    static var mock: AttachmentsSectionViewModel {
        .init(vaultItemsService: MockServicesContainer().vaultItemsService,
              item: item,
              usageLogService: UsageLogService.fakeService,
              documentStorageService: DocumentStorageService.mock,
              attachmentsListViewModelProvider: {_, _ in AttachmentsListViewModel.mock },
              makeAddAttachmentButtonViewModel: .init { _, _, _, _ in AddAttachmentButtonViewModel.mock },
              itemPublisher: Just(item).eraseToAnyPublisher())
    }
}
