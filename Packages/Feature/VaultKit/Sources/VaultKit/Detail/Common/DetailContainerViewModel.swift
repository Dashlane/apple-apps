#if os(iOS)
import Foundation

class DetailContainerViewModel<Item: VaultItem & Equatable>: DetailViewModelProtocol {

    let service: DetailService<Item>

    init(
        service: DetailService<Item>
    ) {
        self.service = service
    }

    func makeAttachmentsSectionViewModel() -> AttachmentsSectionViewModel {
        let publisher = service.vaultItemsService
            .itemPublisher(for: item)
            .map { $0 as VaultItem }
            .eraseToAnyPublisher()
        return service.attachmentSectionFactory.make(item: item, itemPublisher: publisher)
    }
}
#endif
