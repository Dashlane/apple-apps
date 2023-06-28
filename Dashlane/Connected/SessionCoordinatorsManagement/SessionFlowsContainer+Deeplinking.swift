import Foundation
import VaultKit

extension SessionFlowsContainer {

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
extension SessionFlowsContainer {

    func homeFlow() -> HomeFlow {
                return flow(for: .home) as! HomeFlow
    }

    func notificationsFlow() -> NotificationsFlow {
                return flow(for: .notifications) as! NotificationsFlow
    }

        func vaultFlow(
        for deeplink: VaultDeeplink,
        and navigation: NavigationStyle
    ) -> (index: Int, flow: VaultFlow)? {
        let elements = vaultElements(for: navigation)
            .compactMap({ flow(for: $0) as? VaultFlow })
        guard let index = elements
            .firstIndex(where: { $0.viewModel.canHandle(deepLink: deeplink) }) else {
            return nil
        }

        return (Int(index), elements[index])
    }

        func toolsFlow(for deeplink: ToolDeepLinkComponent, and navigation: NavigationStyle) -> (index: Int, flow: ToolsFlow)? {
        let elements = toolsElements(for: navigation)
            .compactMap({ flow(for: $0) as? ToolsFlow })
        guard let index = elements
            .firstIndex(where: { $0.viewModel.canHandle(deeplink: deeplink) }) else {
            return nil
        }

        return (Int(index), elements[index])
    }
}
