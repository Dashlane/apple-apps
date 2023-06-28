import CorePersonalData
import Foundation
import VaultKit

enum NavigationItem: Hashable {
    case home
    case vault(ItemCategory?)
    case contacts
    case tools(ToolsItem?)
    case collection(VaultCollectionNavigation)
    case settings
    case notifications
    case passwordGenerator
}

struct VaultCollectionNavigation: Hashable, Equatable {

    let collection: VaultCollection

    func hash(into hasher: inout Hasher) {
        hasher.combine(collection.id)
    }

    static func == (lhs: VaultCollectionNavigation, rhs: VaultCollectionNavigation) -> Bool {
        lhs.collection.id == rhs.collection.id
    }
}
