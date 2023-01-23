import Foundation
import CorePremium
import UIKit
import DashlaneAppKit
import SwiftTreats
import SwiftUI
import PremiumKit

extension ConnectedCoordinator {

        func didReceiveDeepLink(_ deepLink: DeepLink) {
        guard let splitVC = self.window.rootViewController as? UISplitViewController else { return }
        guard let tabBarVC = splitVC.viewControllers.first as? TabSelectable ?? splitVC.viewController(for: .primary) as? TabSelectable else {
            return
        }

        if let presentedViewController = splitVC.presentedViewController {
            presentedViewController.dismiss(animated: true, completion: {
                self.didReceiveDeepLink(deepLink)
            })
            return
        }
        handleDeeplink(deepLink, tabBarVC: tabBarVC, splitVC: splitVC)
    }

        private func handleDeeplink(_ deepLink: DeepLink,
                                tabBarVC: TabSelectable,
                                splitVC: UISplitViewController) {
        switch deepLink {
        case .prefilledCredential(let password):
            tabBarVC.selectTab(ConnectedCoordinator.Tab.home, coordinator: nil)
            self.sessionCoordinatorsContainer.homeCoordinator().createCredential(using: password)
        case let .vault(vaultDeepLink):
            handleVaultDeeplink(vaultDeepLink, tabBarVC: tabBarVC)
        case .tool(let toolDeeplink, let origin):
            switch toolDeeplink {
            case .otherTool(.generator), .otherTool(.history):
                tabBarVC.selectTab(.passwordGenerator, coordinator: nil)
                return
            default: break
            }

            guard let toolsCoordinator = self.sessionCoordinatorsContainer.toolsCoordinator(for: toolDeeplink, and: currentNavigationStyle) else {
                tabBarVC.selectTab(ConnectedCoordinator.Tab.tools, coordinator: nil)
                return
            }
            tabBarVC.selectTab(ConnectedCoordinator.Tab.tools, coordinator: toolsCoordinator.coordinator)
            toolsCoordinator.coordinator.handleDeepLink(toolDeeplink, origin: origin)
        case .search(let query):
            tabBarVC.selectTab(ConnectedCoordinator.Tab.home, coordinator: nil)
            self.sessionCoordinatorsContainer.homeCoordinator().displaySearch(for: query)
        case .settings:
            if Device.isIpadOrMac {
                self.presentSettings()
            } else {
                tabBarVC.selectTab(ConnectedCoordinator.Tab.settings, coordinator: nil)
            }
        case .other(let otherDeeplink, let origin):
            switch otherDeeplink {
            case .contacts, .sharing:
                guard !Device.isIpadOrMac else {
                    tabBarVC.selectTab(.contacts, coordinator: nil)
                    return
                }
                guard let toolsCoordinator = self.sessionCoordinatorsContainer.toolsCoordinator(for: .otherTool(.contacts), and: currentNavigationStyle) else {
                    tabBarVC.selectTab(.tools, coordinator: nil)
                    return
                }
                tabBarVC.selectTab(ConnectedCoordinator.Tab.tools, coordinator: toolsCoordinator.coordinator)
                toolsCoordinator.coordinator.handleDeepLink(.otherTool(.contacts), origin: origin)
            case .dashboard:
                tabBarVC.selectTab(ConnectedCoordinator.Tab.home, coordinator: nil)
                        case .devices: break
            case .gettingStarted: break
            case .getPremium:
                showPremium(with: .list)
            case .m2wOnboarding:
                showM2W(origin: origin)
            case .safariSessionSharing:
                #if targetEnvironment(macCatalyst)
                sessionServices.appServices.safariExtensionService.refreshSafariSession()
                #else
                break
                #endif
            }
        case .planPurchase(let initialView):
            showPremium(with: initialView)
        case let .token(token):
            modalCoordinator.showSecurityTokenAlert(withToken: token)
                    case .userNotConnected: break
        case .importMethod(let importMethod):
            tabBarVC.selectTab(ConnectedCoordinator.Tab.home, coordinator: nil)
            self.sessionCoordinatorsContainer.homeCoordinator().presentImport(for: importMethod)
        case .notifications(let category):
            guard let notificationsCoordinator = self.sessionCoordinatorsContainer.notificationsCoordinator() else { return }
            tabBarVC.selectTab(.notifications, coordinator: notificationsCoordinator)
            if let category = category {
                notificationsCoordinator.display(category: category)
            }
        }
    }

    private func handleVaultDeeplink(_ vaultDeepLink: VaultDeeplink, tabBarVC: TabSelectable) {
        guard Device.isIpadOrMac else {
                        tabBarVC.selectTab(ConnectedCoordinator.Tab.home, coordinator: nil)
            sessionCoordinatorsContainer.homeCoordinator().handle(vaultDeepLink)
            return
        }

        guard let (_, vaultCoordinator) = self.sessionCoordinatorsContainer.vaultCoordinator(for: vaultDeepLink, and: currentNavigationStyle) else {
            tabBarVC.selectTab(ConnectedCoordinator.Tab.home, coordinator: nil)
            sessionCoordinatorsContainer.homeCoordinator().handle(vaultDeepLink)
            return
        }

        if vaultCoordinator.shouldShowHomeSection(for: vaultDeepLink) {
            tabBarVC.selectTab(ConnectedCoordinator.Tab.home, coordinator: nil)
        } else {
            tabBarVC.selectTab(ConnectedCoordinator.Tab.vault, coordinator: vaultCoordinator)
        }
        vaultCoordinator.handle(vaultDeepLink)
    }

        private func showM2W(origin: String? = nil) {
        guard let parentViewController = window.rootViewController?.topVisibleViewController else {
            fatalError("Can't find parentViewController")
        }

        let model = M2WFlowViewModel(initialStep: .init(origin: .init(string: origin)))
        let navigator = DashlaneNavigationController()

        let view = M2WFlowView(viewModel: model) { action in
            switch action {
            case .success:
                let settings = M2WSettings(userSettings: self.sessionServices.userSettings)
                settings.setUserHasFinishedM2W()
            default: break
            }
            navigator.dismiss(animated: true)
        }

        navigator.push(view, barStyle: .hidden(), animated: false)
        parentViewController.present(navigator, animated: true)
    }

    func showPremium(with initialView: PlanPurchaseInitialViewRequest) {
        guard let parentViewController = window.rootViewController?.topVisibleViewController else {
            fatalError("Can't find parentViewController")
        }
        let navigator = DashlaneNavigationController()
        let planPurchaseFlowView = PurchaseFlowView(model: .init(initialView: initialView, planPurchaseServices: sessionServices.makePlanPurchaseServices())) { _ in
            navigator.dismiss(animated: true)
        }
        navigator.push(planPurchaseFlowView, barStyle: .transparent(), animated: false)
        parentViewController.present(navigator, animated: true)
    }
}

extension UITabBarController: TabSelectable {
    func selectTab(_ tab: ConnectedCoordinator.Tab, coordinator: TabCoordinator?) {
        selectedIndex = tab.tabBarIndexValue
    }
}
