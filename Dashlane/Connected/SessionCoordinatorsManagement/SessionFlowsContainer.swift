import Foundation
import VaultKit
import SwiftUI

enum NavigationStyle {
    case tabBar
    case sidebar
}

@MainActor
class SessionFlowsContainer {

    let sessionServices: SessionServicesContainer

    private(set) var flows: [NavigationItem: any TabFlow] = [:]

    struct SectionItem {
       let title: String?
       let items: [NavigationItem]
   }

    init(sessionServices: SessionServicesContainer) {
        self.sessionServices = sessionServices
    }

        var tabBarElements: [NavigationItem] {
        [
            .home,
            .notifications,
            .passwordGenerator,
            .tools(nil),
            .settings
        ]
    }

            var sidebarElements: [SectionItem] {
        [
            .init(title: nil,
                  items: [.home, .notifications]),
            .init(title: L10n.Localizable.tabVaultTitle,
                  items: vaultSectionNavigationItems(sessionServices: sessionServices)),
            .init(title: L10n.Localizable.sidebarToolsTitle,
                  items: toolsNavigationItems(sessionServices: sessionServices))
        ]
    }
}

@MainActor
extension SessionFlowsContainer {
    private func makeFlow(for item: NavigationItem) -> any TabFlow {
        switch item {
        case .home:
            return HomeFlow(viewModel: self.sessionServices.makeHomeFlowViewModel())
        case let .vault(item):
            return VaultFlow(viewModel: self.sessionServices.makeVaultFlowViewModel(itemCategory: item))
        case .contacts:
            return SharingToolsFlow(viewModel: self.sessionServices.makeSharingToolsFlowViewModel())
        case let .tools(item):
            return ToolsFlow(viewModel: self.sessionServices.makeToolsFlowViewModel(toolsItem: item))
        case let .collection(collectionNavigation):
            return CollectionsFlow(viewModel: self.sessionServices.makeCollectionsFlowViewModel(initialStep: .collectionDetail(collectionNavigation.collection)))
        case .settings:
            return SettingsFlowView(viewModel: self.sessionServices.makeSettingsFlowViewModel())
        case .notifications:
            return NotificationsFlow(viewModel: self.sessionServices.makeNotificationsFlowViewModel(notificationCenterService: self.sessionServices.makeNotificationCenterService()))
        case .passwordGenerator:
            return PasswordGeneratorToolsFlow(embedInNavigationView: true,
                                              viewModel: self.sessionServices.makePasswordGeneratorToolsFlowViewModel(pasteboardService: PasteboardService(userSettings: self.sessionServices.userSettings)))
        }
    }

            func flow(for item: NavigationItem) -> any TabFlow {
        if let flow = flows[item] {
            return flow
        }
        let flow = makeFlow(for: item)
        flows[item] = flow
        return flow
    }
}

@MainActor
extension SessionFlowsContainer {
    func tabBarFlows() -> [any TabFlow] {
        return tabBarElements
            .map {
                return self.flow(for: $0)
             }
    }
}

private extension SessionFlowsContainer {

    func vaultSectionNavigationItems(sessionServices: SessionServicesContainer) -> [NavigationItem] {
        return vaultNavigationItems(sessionServices: sessionServices) + [.contacts]
    }

    func vaultNavigationItems(sessionServices: SessionServicesContainer) -> [NavigationItem] {
        ItemCategory.allCases
            .filter({ $0.showable(sessionServices: sessionServices) })
            .map({ .vault($0) })
    }
}

 private extension SessionFlowsContainer {
    func toolsNavigationItems(sessionServices: SessionServicesContainer) -> [NavigationItem] {
        sessionServices.toolsService.availableNavigationToolItems().map({ .tools($0) })
    }
 }
