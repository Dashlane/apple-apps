import Foundation
import VaultKit

class DetailContainerViewModel<Item: VaultItem & Equatable>: DetailViewModelProtocol {

    let service: DetailService<Item>

    init(service: DetailService<Item>) {
        self.service = service
    }
}
