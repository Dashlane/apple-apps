#if os(iOS)
import Foundation
import CorePersonalData

public final class CollectionsSectionModel<Item: VaultItem & Equatable>: DetailViewModelProtocol {

    public let service: DetailService<Item>

    public init(service: DetailService<Item>) {
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
#endif
