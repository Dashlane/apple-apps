import SwiftUI
import UIDelight
import SwiftTreats

struct ToolsFlow: View {

    @StateObject
    var viewModel: ToolsFlowViewModel

    init(viewModel: @autoclosure @escaping () -> ToolsFlowViewModel) {
        self._viewModel = .init(wrappedValue: viewModel())
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
                VPNTeamPaywallView()
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
            PasswordGeneratorToolsFlow(viewModel: viewModel.passwordGeneratorToolsFlowViewModelFactory.make())
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
        }
    }
}

struct ToolsFlow_Previews: PreviewProvider {
    static var previews: some View {
        ToolsFlow(viewModel: .mock(item: nil))
        ToolsFlow(viewModel: .mock(item: .identityDashboard))
    }
}
