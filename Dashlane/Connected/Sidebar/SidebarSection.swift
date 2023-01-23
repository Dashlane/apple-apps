import Foundation

struct SidebarSection: Hashable {
    let tabCoordinator: SidebarSectionCoordinators

    static func == (lhs: SidebarSection, rhs: SidebarSection) -> Bool {
        return lhs.tabCoordinator == rhs.tabCoordinator
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(tabCoordinator)
    }
}
