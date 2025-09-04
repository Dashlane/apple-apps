import Combine
import CorePersonalData
import CorePremium
import CoreSession
import CoreSharing
import CoreTypes
import Foundation
import VaultKit

@MainActor
class SharingToolItemsProvider: SessionServicesInjecting {
  @Published
  var vaultItemByIds: [Identifier: VaultItem] = [:]

  @Published
  var sharedIds: Set<Identifier> = []

  public init(
    vaultItemsStore: VaultItemsStore,
    userSpacesService: UserSpacesService
  ) {
    var publishers: [AnyPublisher<[VaultItem], Never>] = []

    for type in SharingType.allCases {
      switch type {
      case .password:
        publishers.append(
          vaultItemsStore.$credentials.map { $0 as [VaultItem] }.eraseToAnyPublisher())
      case .note:
        publishers.append(
          vaultItemsStore.$secureNotes.map { $0 as [VaultItem] }.eraseToAnyPublisher())
      case .secret:
        publishers.append(vaultItemsStore.$secrets.map { $0 as [VaultItem] }.eraseToAnyPublisher())
      }
    }

    publishers.combineLatest()
      .map { items in items.flatMap { $0 } }
      .filter(by: userSpacesService.$configuration)
      .map { items in
        var itemByIds = [Identifier: VaultItem]()
        for item in items {
          itemByIds[item.id] = item
        }
        return itemByIds
      }
      .receive(on: DispatchQueue.main)
      .assign(to: &$vaultItemByIds)

    $vaultItemByIds.map { Set($0.keys) }.assign(to: &$sharedIds)
  }

  private init(vaultItemByIds: [Identifier: VaultItem] = [:]) {
    self.vaultItemByIds = vaultItemByIds
    self.sharedIds = Set(vaultItemByIds.keys)
  }
}

extension SharingToolItemsProvider {
  static func mock(vaultItemByIds: [Identifier: VaultItem] = [:]) -> SharingToolItemsProvider {
    SharingToolItemsProvider(vaultItemByIds: vaultItemByIds)
  }
}
