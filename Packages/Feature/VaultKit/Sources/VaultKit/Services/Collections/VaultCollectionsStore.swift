import Combine

public class VaultCollectionsPublishersStore {

  @Published public internal(set) var collections: [VaultCollection]

  public init(
    collections: [VaultCollection] = []
  ) {
    self.collections = collections
  }
}

public protocol VaultCollectionsStore: VaultCollectionsPublishersStore {
  func collectionsPublisher<Output: VaultItem>(for vaultItem: Output) -> AnyPublisher<
    [VaultCollection], Never
  >
}
