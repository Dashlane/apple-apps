import Combine
import Foundation

public protocol VaultItemsLimitServiceProtocol {
  var credentialsLimitPublisher: Published<VaultItemsLimit>.Publisher { get }
  func canAddNewItem(for vaultItem: VaultItem.Type) -> Bool
  func canAddNewItem(for category: ItemCategory) -> Bool
}

class VaultItemsLimitServiceMock: VaultItemsLimitServiceProtocol {

  @Published
  var credentialsLimit: VaultItemsLimit
  var credentialsLimitPublisher: Published<VaultItemsLimit>.Publisher { $credentialsLimit }

  init(credentialsLimit: VaultItemsLimit) {
    self.credentialsLimit = credentialsLimit
  }

  func canAddNewItem(for vaultItem: VaultItem.Type) -> Bool {
    return !credentialsLimit.isLimited
  }

  func canAddNewItem(for category: ItemCategory) -> Bool {
    return !credentialsLimit.isLimited
  }
}

extension VaultItemsLimitServiceProtocol where Self == VaultItemsLimitServiceMock {
  static var mock: VaultItemsLimitServiceMock {
    .init(credentialsLimit: .limited(count: 10, limit: 10, enforceFreeze: false))
  }
}
