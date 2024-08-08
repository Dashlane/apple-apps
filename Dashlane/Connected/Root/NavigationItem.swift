import CorePersonalData
import Foundation
import VaultKit

enum NavigationItem: Hashable {
  case home
  case vault(ItemCategory?)
  case tools(ToolsItem?)
  case collection(CollectionNavigation)
  case settings
  case notifications
}

struct CollectionNavigation: Hashable, Equatable {

  let collection: VaultCollection

  func hash(into hasher: inout Hasher) {
    hasher.combine(collection.id)
  }

  static func == (lhs: CollectionNavigation, rhs: CollectionNavigation) -> Bool {
    lhs.collection.id == rhs.collection.id
  }
}
