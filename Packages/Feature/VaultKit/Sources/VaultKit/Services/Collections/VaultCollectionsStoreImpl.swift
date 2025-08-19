import Combine
import CorePersonalData
import CoreTypes
import Foundation
import LogFoundation

public final class VaultCollectionsStoreImpl:
  VaultCollectionsPublishersStore,
  VaultCollectionsStore
{

  private let logger: Logger
  private let vaultCollectionDatabase: VaultCollectionDatabaseProtocol
  private var subscriptions = Set<AnyCancellable>()

  init(
    logger: Logger,
    vaultCollectionDatabase: VaultCollectionDatabaseProtocol
  ) {
    self.logger = logger
    self.vaultCollectionDatabase = vaultCollectionDatabase

    super.init()
    configureLists()
  }

  private func configureLists() {
    vaultCollectionDatabase
      .collectionsPublisher()
      .assign(to: &$collections)
  }

  public func collectionsPublisher<Output: VaultItem>(
    for vaultItem: Output
  ) -> AnyPublisher<[VaultCollection], Never> {
    $collections
      .map { collections in collections.filter(by: vaultItem) }
      .receive(on: DispatchQueue.main)
      .eraseToAnyPublisher()
  }
}

extension VaultCollectionsStore where Self == VaultCollectionsStoreImpl {
  public static func mock(database: VaultCollectionDatabase = .mock()) -> VaultCollectionsStore {
    VaultCollectionsStoreImpl(
      logger: .mock,
      vaultCollectionDatabase: database
    )
  }
}
