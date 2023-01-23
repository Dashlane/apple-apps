import Foundation
import CorePersonalData
import VaultKit

final class CollectionsSectionModel<Item: VaultItem & Equatable>: DetailViewModelProtocol {

    let service: DetailService<Item>

    init(service: DetailService<Item>) {
        self.service = service
    }
}

extension CollectionsSectionModel {
    static func mock(
        service: DetailService<Item>
    ) -> CollectionsSectionModel {
        CollectionsSectionModel(
            service: service
        )
    }
}
