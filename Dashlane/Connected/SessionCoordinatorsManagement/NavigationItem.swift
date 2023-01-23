import Foundation

enum NavigationItem: Hashable {
    case home
    case vault(ItemCategory?)
    case contacts
    case tools(ToolsItem?)
    case settings
    case notifications
    case passwordGenerator
}
