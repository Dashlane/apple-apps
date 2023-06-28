#if os(iOS)
import Foundation
import CorePersonalData
import Combine
import DocumentServices

public class AttachmentsSectionViewModel: ObservableObject, VaultKitServicesInjecting {

    @Published
    var item: VaultItem

    @Published
    var progress: Double?

    private let itemPublisher: AnyPublisher<VaultItem, Never>
    let addAttachmentButtonViewModel: AddAttachmentButtonViewModel
    private let attachmentsListViewModelProvider: (VaultItem, AnyPublisher<VaultItem, Never>) -> AttachmentsListViewModel
    private let vaultItemsService: VaultItemsServiceProtocol
    private let documentStorageService: DocumentStorageService
    private var subscriptions = Set<AnyCancellable>()

    public init(
        vaultItemsService: VaultItemsServiceProtocol,
        item: VaultItem,
        documentStorageService: DocumentStorageService,
        attachmentsListViewModelProvider: @escaping (VaultItem, AnyPublisher<VaultItem, Never>) -> AttachmentsListViewModel,
        makeAddAttachmentButtonViewModel: AddAttachmentButtonViewModel.Factory,
        itemPublisher: AnyPublisher<VaultItem, Never>
    ) {
        self.vaultItemsService = vaultItemsService
        self.documentStorageService = documentStorageService
        self.attachmentsListViewModelProvider = attachmentsListViewModelProvider
        self.itemPublisher = itemPublisher
        self.item = item
        self.addAttachmentButtonViewModel = makeAddAttachmentButtonViewModel.make(editingItem: item,
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
        .init(vaultItemsService: MockVaultKitServicesContainer().vaultItemsService,
              item: item,
              documentStorageService: DocumentStorageService.mock,
              attachmentsListViewModelProvider: {_, _ in AttachmentsListViewModel.mock },
              makeAddAttachmentButtonViewModel: .init { _, _, _ in AddAttachmentButtonViewModel.mock },
              itemPublisher: Just(item).eraseToAnyPublisher())
    }
}
#endif
