import Foundation

protocol TabSelectable {
    func selectTab(_ tab: ConnectedCoordinator.Tab, coordinator: TabCoordinator?)
}
