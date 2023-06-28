import SwiftUI
import UIDelight
import SwiftTreats
import DesignSystem
import VaultKit

struct ToolsFlow: TabFlow {

        let tag: Int = 0
    let id: UUID = .init()
    let title: String
    let tabBarImage: NavigationImageSet

    @ObservedObject
    var viewModel: ToolsFlowViewModel

    init(viewModel: ToolsFlowViewModel) {
        self.viewModel = viewModel
        self.title = viewModel.toolsItem?.title ?? L10n.Localizable.tabToolsTitle
        self.tabBarImage = viewModel.toolsItem?.tabBarImage ?? .init(image: .ds.tools.outlined,
                                                                 selectedImage: .ds.tools.filled)
    }

    var body: some View {
        StepBasedNavigationView(steps: $viewModel.steps) { step in
            switch step {
            case .root:
                ToolsView(viewModel: viewModel.toolsViewModelFactory.make(didSelectItem: viewModel.didSelectItem))
            case .item(let item):
                view(for: item)
                    .hideTabBar()
                    .navigationBarTitleDisplayMode(.inline)
            case .placeholder(let item):
                SplitViewPlaceholderView()
                    .onAppear {
                        if Device.isIpadOrMac {
                            viewModel.didSelect(item: item)
                        }
                    }
            case let .unresolvedAlert(alert):
                UnresolvedAlertView(viewModel: viewModel.unresolvedAlertViewModelFactory.make(),
                                    trayAlert: alert.alert)
                .hideTabBar()
                .navigationBarTitleDisplayMode(.inline)
            }
        }
        .tint(.ds.text.brand.standard)
        .onReceive(viewModel.deeplinkPublisher) { deeplink in
            switch deeplink {
            case let .tool(toolDeeplink, origin):
                self.handle(toolDeeplink: toolDeeplink, origin: origin)
            case let .other(otherToolDeeplink, _):
                switch otherToolDeeplink {
                case .contacts, .sharing:
                    guard !Device.isIpadOrMac else { return }
                    self.handle(toolDeeplink: .otherTool(.contacts), origin: nil)
                default: break
                }
            default: break
            }
        }
        .sheet(item: $viewModel.presentedSheet) { sheet in
            switch sheet {
            case let .showM2W(origin):
                M2WFlowView(viewModel: viewModel.makeM2WViewModel(origin: origin), completion: viewModel.dismissM2W)
            case .vpnPremiumPaywall:
                VPNPaywallView(reason: viewModel.vpnService.reasonOfUnavailability == .premium ? .upgradeNeeded : .trialPeriod) {
                    viewModel.deepLinkingService.handleLink(.planPurchase(initialView: .plan(kind: .premium)))
                } secondaryButtonAction: {
                    viewModel.deepLinkingService.handleLink(.planPurchase(initialView: .list))
                }
            case .vpnB2BDisabled:
                VPNTeamFeatureDisabledView()
            }
        }
    }

    @ViewBuilder
    func view(for item: ToolsItem) -> some View {
        switch item {
        case .identityDashboard:
            PasswordHealthFlowView(viewModel: viewModel.passwordHealthFlowViewModelFactory.make(origin: .identityDashboard))
        case .authenticator:
            AuthenticatorToolFlowView(viewModel: viewModel.authenticatorToolFlowViewModelFactory.make())
        case .passwordGenerator:
            PasswordGeneratorToolsFlow(viewModel: viewModel.passwordGeneratorToolsFlowViewModelFactory.make(pasteboardService: PasteboardService(userSettings: viewModel.userSettings)))
        case .darkWebMonitoring:
            DarkWebToolsFlow(viewModel: viewModel.darkWebToolsFlowViewModelFactory.make())
        case .secureWifi:
            VPNAvailableToolsFlow(viewModel: viewModel.vpnAvailableToolsFlowViewModelFactory.make())
        case .contacts:
            SharingToolsFlow(viewModel: viewModel.sharingToolsFlowViewModelFactory.make())
        case .multiDevices:
            SplitViewPlaceholderView()
                .onAppear {
                                        assert(Device.isIpadOrMac)
                    self.viewModel.presentedSheet = .showM2W(nil)
                }
        case .collections:
            CollectionsFlow(viewModel: viewModel.collectionsFlowViewModelFactory.make())
        }
    }

    private func handle(toolDeeplink: ToolDeepLinkComponent, origin: String?) {
        guard self.viewModel.canHandle(deeplink: toolDeeplink) else { return }
        self.viewModel.handleDeepLink(toolDeeplink, origin: origin)
    }
}

struct ToolsFlow_Previews: PreviewProvider {
    static var previews: some View {
        ToolsFlow(viewModel: .mock(item: nil))
        ToolsFlow(viewModel: .mock(item: .identityDashboard))
    }
}
