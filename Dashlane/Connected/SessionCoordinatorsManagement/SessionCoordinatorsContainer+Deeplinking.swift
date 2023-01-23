import Foundation

extension SessionCoordinatorsContainer {

        private func elements(for navigation: NavigationStyle) -> [NavigationItem] {
        switch navigation {
        case .tabBar:
            return self.tabBarElements
        case .sidebar:
            return self.sidebarElements
                .flatMap({ $0.items })
        }
    }
        func vaultElements(for navigation: NavigationStyle) -> [NavigationItem] {
        return elements(for: navigation).filter {
            if case NavigationItem.vault = $0 {
                return true
            } else {
                return false
            }
        }
    }

        func toolsElements(for navigation: NavigationStyle) -> [NavigationItem] {
        return elements(for: navigation).filter {
            if case NavigationItem.tools = $0 {
                return true
            } else {
                return false
            }
        }
    }

}

@MainActor
extension SessionCoordinatorsContainer {

    func homeCoordinator() -> HomeFlowViewModel {
                return coordinator(for: .home) as! HomeFlowViewModel
    }

        func vaultCoordinator(
        for deeplink: VaultDeeplink,
        and navigation: NavigationStyle
    ) -> (index: Int, coordinator: VaultFlowViewModel)? {
        let elements = vaultElements(for: navigation)
            .compactMap({ coordinator(for: $0) as? VaultFlowViewModel })
        guard let index = elements
                .firstIndex(where: { $0.canHandle(deepLink: deeplink) }) else {
            return nil
        }

        return (Int(index), elements[index])
    }

    func contactsCoordinator() -> SharingToolsFlowViewModel? {
        return coordinator(for: .contacts) as? SharingToolsFlowViewModel
    }

        func toolsCoordinator(for deeplink: ToolDeepLinkComponent, and navigation: NavigationStyle) -> (index: Int, coordinator: ToolsFlowViewModel)? {
        let elements = toolsElements(for: navigation)
            .compactMap({ coordinator(for: $0) as? ToolsFlowViewModel })
        guard let index = elements
                .firstIndex(where: { $0.canHandle(deeplink: deeplink) }) else {
            return nil
        }

        return (Int(index), elements[index])
    }

    func settingsCoordinator() -> SettingsCoordinator? {
        return coordinator(for: .settings) as? SettingsCoordinator
    }

    func notificationsCoordinator() -> NotificationCoordinator? {
        return coordinator(for: .notifications) as? NotificationCoordinator
    }
}
