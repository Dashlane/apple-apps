import Combine
import CorePersonalData
import DocumentServices
import Foundation

public class AttachmentsSectionViewModel: ObservableObject, VaultKitServicesInjecting {

  @Published
  var item: VaultItem

  @Published
  var itemCollections: [VaultCollection] = []

  @Published
  var progress: Double?

  var uploadInProgress: Bool {
    progress != nil && progress != 1
  }

  let addAttachmentButtonViewModel: AddAttachmentButtonViewModel
  private let attachmentsListViewModelProvider:
    (VaultItem, AnyPublisher<VaultItem, Never>) -> AttachmentsListViewModel

  private let itemPublisher: AnyPublisher<VaultItem, Never>
  private var subscriptions = Set<AnyCancellable>()

  public init(
    item: VaultItem,
    documentStorageService: DocumentStorageService,
    vaultCollectionsStore: VaultCollectionsStore,
    attachmentsListViewModelProvider: @escaping (VaultItem, AnyPublisher<VaultItem, Never>) ->
      AttachmentsListViewModel,
    makeAddAttachmentButtonViewModel: AddAttachmentButtonViewModel.Factory,
    itemPublisher: AnyPublisher<VaultItem, Never>
  ) {
    self.attachmentsListViewModelProvider = attachmentsListViewModelProvider
    self.itemPublisher = itemPublisher
    self.item = item
    self.addAttachmentButtonViewModel = makeAddAttachmentButtonViewModel.make(
      editingItem: item,
      shouldDisplayRenameAlert: false,
      itemPublisher: itemPublisher)
    itemPublisher
      .receive(on: DispatchQueue.main)
      .assign(to: &$item)

    vaultCollectionsStore.collectionsPublisher(for: item)
      .receive(on: DispatchQueue.main)
      .assign(to: &$itemCollections)

    documentStorageService.$uploads
      .compactMap { uploads -> Progress? in
        uploads
          .first { $0.item().id == self.item.id }
          .flatMap({ $0.progress })
      }
      .map { progress -> AnyPublisher<Double?, Never> in
        return
          progress
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
    .init(
      item: item,
      documentStorageService: DocumentStorageService.mock,
      vaultCollectionsStore: VaultCollectionsStoreImpl.mock(),
      attachmentsListViewModelProvider: { _, _ in AttachmentsListViewModel.mock },
      makeAddAttachmentButtonViewModel: .init { _, _, _ in AddAttachmentButtonViewModel.mock },
      itemPublisher: Just(item).eraseToAnyPublisher()
    )
  }
}
