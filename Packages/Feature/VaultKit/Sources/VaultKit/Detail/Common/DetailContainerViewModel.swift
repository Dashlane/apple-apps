import CorePersonalData
import Foundation

class DetailContainerViewModel<Item: VaultItem & Equatable>: DetailViewModelProtocol {

  let service: DetailService<Item>

  init(
    service: DetailService<Item>
  ) {
    self.service = service
  }

  func makeAttachmentsSectionViewModel() -> AttachmentsSectionViewModel {
    let publisher = service.vaultItemDatabase
      .itemPublisher(for: item)
      .map { $0 as VaultItem }
      .receive(on: DispatchQueue.main)
      .eraseToAnyPublisher()
    return service.attachmentSectionFactory.make(item: item, itemPublisher: publisher)
  }
}
