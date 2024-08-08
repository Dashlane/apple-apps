import DesignSystem
import MacrosKit
import SwiftTreats
import SwiftUI
import UIDelight
import VaultKit

@ViewInit
struct ToolsFlow: View {
  @StateObject
  var viewModel: ToolsFlowViewModel

  var body: some View {
    StepBasedContentNavigationView(steps: $viewModel.steps) { step in
      switch step {
      case .root:
        ToolsView(
          viewModel: viewModel.toolsViewModelFactory.make(didSelectItem: viewModel.didSelectItem))
      case .item(let item):
        view(for: item)
          .navigationBarTitleDisplayMode(.inline)
          .toolbar(.hidden, for: .tabBar)

      case .placeholder(let item):
        SplitViewPlaceholderView()
          .onAppear {
            if Device.isIpadOrMac {
              viewModel.didSelect(item: item)
            }
          }
      case let .unresolvedAlert(alert):
        UnresolvedAlertView(
          viewModel: viewModel.unresolvedAlertViewModelFactory.make(),
          trayAlert: alert.alert
        )
        .toolbar(.hidden, for: .tabBar)
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
        M2WFlowView(
          viewModel: viewModel.makeM2WViewModel(origin: origin), completion: viewModel.dismissM2W)
      case .vpnB2BDisabled:
        VPNTeamFeatureDisabledView()
      case .showAddNewDevice:
        AddNewDeviceView(model: viewModel.makeAddNewDeviceViewModel())
      }
    }
  }

  @ViewBuilder
  func view(for item: ToolsItem) -> some View {
    switch item {
    case .identityDashboard:
      PasswordHealthFlowView(
        viewModel: viewModel.passwordHealthFlowViewModelFactory.make(origin: .identityDashboard))
    case .authenticator:
      AuthenticatorToolFlowView(viewModel: viewModel.authenticatorToolFlowViewModelFactory.make())
    case .passwordGenerator:
      PasswordGeneratorToolsFlow(
        viewModel: viewModel.passwordGeneratorToolsFlowViewModelFactory.make())
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
          self.viewModel.presentedSheet =
            (viewModel.isPasswordlessAccount || Device.isMac) ? .showAddNewDevice : .showM2W(nil)
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
