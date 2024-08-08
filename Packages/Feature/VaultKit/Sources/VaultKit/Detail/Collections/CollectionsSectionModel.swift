import Combine
import CorePersonalData
import Foundation

public final class CollectionsSectionModel<Item: VaultItem & Equatable>: DetailViewModelProtocol {

  public let service: DetailService<Item>

  private var cancellables: Set<AnyCancellable> = []

  public init(service: DetailService<Item>) {
    self.service = service
    registerServiceChanges()
  }

  private func registerServiceChanges() {
    service.vaultCollectionEditionService
      .objectWillChange
      .receive(on: DispatchQueue.main)
      .sink { [weak self] in
        self?.objectWillChange.send()
      }
      .store(in: &cancellables)
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
