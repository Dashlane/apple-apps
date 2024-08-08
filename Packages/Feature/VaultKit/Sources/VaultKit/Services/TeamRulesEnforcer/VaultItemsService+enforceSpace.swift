import CorePremium
import Foundation

extension VaultItemDatabaseProtocol {
  func enforceSpaceIfNeeded<Item: VaultItem>(
    on items: [Item], for configuration: UserSpacesService.SpacesConfiguration
  ) throws {
    let itemsToUpdate = items.compactMap { item -> Item? in
      guard let forcedSpace = configuration.forcedSpace(for: item),
        let fetchingSpace = configuration.virtualUserSpace(for: item),
        fetchingSpace != forcedSpace
      else {
        return nil
      }

      var item = item
      item.spaceId = forcedSpace.personalDataId
      return item
    }

    guard !itemsToUpdate.isEmpty else {
      return
    }

    _ = try save(itemsToUpdate)
  }
}
