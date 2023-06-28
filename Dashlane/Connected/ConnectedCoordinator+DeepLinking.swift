import Foundation
import CorePremium
import UIKit
import DashlaneAppKit
import SwiftTreats
import SwiftUI
import PremiumKit
import VaultKit
import UIComponents

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
        case .prefilledCredential:
            tabBarVC.selectTab(ConnectedCoordinator.Tab.home)
        case let .vault(vaultDeepLink):
            handleVaultDeeplink(vaultDeepLink, tabBarVC: tabBarVC)
        case .tool(let toolDeeplink, _):
            switch toolDeeplink {
            case .otherTool(.generator), .otherTool(.history):
                tabBarVC.selectTab(.passwordGenerator)
                return
            default: break
            }

            guard let toolsFlow = self.sessionFlowsContainer.toolsFlow(for: toolDeeplink, and: currentNavigationStyle) else {
                tabBarVC.selectTab(ConnectedCoordinator.Tab.tools)
                return
            }
            tabBarVC.selectTab(ConnectedCoordinator.Tab.tools, flow: toolsFlow.flow)
        case .search:
            tabBarVC.selectTab(ConnectedCoordinator.Tab.home)
        case .settings:
            if Device.isIpadOrMac {
                self.presentSettingsFromSidebar()
            } else {
                tabBarVC.selectTab(ConnectedCoordinator.Tab.settings)
            }
        case .other(let otherDeeplink, let origin):
            switch otherDeeplink {
            case .contacts, .sharing:
                guard !Device.isIpadOrMac else {
                    tabBarVC.selectTab(.contacts)
                    return
                }
                guard let toolsFlow = self.sessionFlowsContainer.toolsFlow(for: .otherTool(.contacts), and: currentNavigationStyle) else {
                    tabBarVC.selectTab(.tools)
                    return
                }
                tabBarVC.selectTab(ConnectedCoordinator.Tab.tools, flow: toolsFlow.flow)
            case .dashboard:
                tabBarVC.selectTab(ConnectedCoordinator.Tab.home)
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
        case .importMethod:
            tabBarVC.selectTab(ConnectedCoordinator.Tab.home)
        case .notifications:
            tabBarVC.selectTab(.notifications, flow: sessionFlowsContainer.notificationsFlow())
        case let .mplessLogin(qrcode):
            tabBarVC.selectTab(ConnectedCoordinator.Tab.settings)
            showMpLess(withQRCode: qrcode)
        }
    }

    private func handleVaultDeeplink(_ vaultDeepLink: VaultDeeplink, tabBarVC: TabSelectable) {
        guard Device.isIpadOrMac else {
                        tabBarVC.selectTab(ConnectedCoordinator.Tab.home)
            return
        }

        guard let (_, vaultFlow) = self.sessionFlowsContainer.vaultFlow(for: vaultDeepLink, and: currentNavigationStyle) else {
            tabBarVC.selectTab(ConnectedCoordinator.Tab.home)
            return
        }

        if vaultDeepLink.shouldShowHomeSection {
            tabBarVC.selectTab(ConnectedCoordinator.Tab.home)
        } else {
            tabBarVC.selectTab(ConnectedCoordinator.Tab.vault, flow: vaultFlow)
        }
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

    func showMpLess(withQRCode qrcode: String) {
        guard let parentViewController = window.rootViewController?.topVisibleViewController else {
            fatalError("Can't find parentViewController")
        }
        let navigator = DashlaneNavigationController()
        let addNewDeviceView = AddNewDeviceView(model: self.sessionServices.viewModelFactory.makeAddNewDeviceViewModel(qrCodeViaSystemCamera: qrcode))
        navigator.push(addNewDeviceView, barStyle: .transparent(), animated: false)
        parentViewController.present(UIHostingController(rootView: addNewDeviceView), animated: true)
    }
}

extension UITabBarController: TabSelectable {
    func selectTab(_ tab: ConnectedCoordinator.Tab, flow: any TabFlow) {
        selectedIndex = tab.tabBarIndexValue
    }

    func selectTab(_ tab: ConnectedCoordinator.Tab) {
        selectedIndex = tab.tabBarIndexValue
    }
}

private extension VaultDeeplink {
    var shouldShowHomeSection: Bool {
        switch self {
        case let .list(category):
            return category == nil
        case .fetchAndShow, .show, .create:
            return false
        }
    }
}
