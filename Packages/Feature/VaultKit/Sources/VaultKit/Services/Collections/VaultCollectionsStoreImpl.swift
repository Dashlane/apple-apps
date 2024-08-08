import Combine
import DashTypes
import Foundation

final class VaultCollectionsStoreImpl:
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

    $collections
      .receive(on: DispatchQueue.global(qos: .background))
      .sink { [weak self] collecitons in
        self?.logUnknownXMLDataType(in: collecitons)
      }.store(in: &subscriptions)
  }

  private func logUnknownXMLDataType(in collections: [VaultCollection]) {
    for collection in collections {
      guard let privateCollection = collection.privateCollection,
        case let types = privateCollection.items.filter({ $0.type == nil }).map(\.$type),
        !types.isEmpty
      else {
        continue
      }

      logger.fatal("Unknown types [\(types.joined(separator: ","))] in collection \(collection.id)")
    }
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
  static func mock(database: VaultCollectionDatabase = .mock()) -> VaultCollectionsStore {
    VaultCollectionsStoreImpl(
      logger: LoggerMock(),
      vaultCollectionDatabase: database
    )
  }
}
