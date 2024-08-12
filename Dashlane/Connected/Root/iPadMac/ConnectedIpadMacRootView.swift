import MacrosKit
import SwiftUI

@ViewInit
struct ConnectedIpadMacRootView: View {
  @StateObject
  var model: ConnectedIpadMacRootViewModel

  @State
  var sidebarWidth: Double = 0

  var body: some View {
    NavigationView {
      SidebarView(model: model.sidebarViewModel)
        #if targetEnvironment(macCatalyst)
          .navigationSplitViewColumnWidth(min: 280, ideal: 300, max: 500)
        #endif
        .onSizeChange { size in
          sidebarWidth = size.width
        }
      detail(for: model.selection)
    }
    .navigationSplitViewStyle(.prominentDetail)
    .onReceive(model.deepLinkPublisher, perform: handle)
    .toasterOn(offsetX: sidebarWidth)
  }

  func handle(_ deepLink: DeepLink) {
    switch deepLink {
    case .prefilledCredential,
      .search,
      .importMethod,
      .other(.dashboard, _):
      model.select(.home)

    case let .vault(vault):
      guard let selection = model.selection(for: vault) else {
        return
      }

      model.select(selection)

    case .tool(let toolDeeplink, _):
      if case .unresolvedAlert = toolDeeplink {
        model.select(.notifications)
      } else if let tool = ToolsItem(deepLink: toolDeeplink) {
        model.select(.tools(tool))
      }
    case .settings, .mplessLogin:
      model.displaySettings()

    case .notifications:
      model.select(.notifications)

    case .other(.contacts, _), .other(.sharing, _):
      model.select(.tools(.contacts))

    default: break

    }
  }

  @ViewBuilder
  func detail(for selection: NavigationItem?) -> some View {
    switch selection {
    case .home:
      HomeFlow(viewModel: model.homeFlowViewModelFactory.make())
        .id(NavigationItem.home)

    case .notifications:
      NotificationsFlow(viewModel: model.notificationViewModel)

    case .vault(let itemCategory):
      if let itemCategory, let model = model.vaultFlowViewModels[itemCategory] {
        VaultFlow(viewModel: model)
          .id(itemCategory)
      }

    case .tools(let toolsItem):
      ToolsFlow(viewModel: model.toolsFlowViewModelFactory.make(toolsItem: toolsItem))
        .id(toolsItem)

    case .collection(let collectionNavigation):
      CollectionsFlow(
        viewModel: model.collectionFlowViewModelFactory.make(
          initialStep: .collectionDetail(collectionNavigation.collection)))

    case .settings:
      EmptyView()

    case .none:
      SplitViewPlaceholderView()
    }
  }
}

extension ToolsItem {
  init?(deepLink: ToolDeepLinkComponent) {
    switch deepLink {
    case .identityDashboard:
      self = .identityDashboard

    case .darkWebMonitoring:
      self = .darkWebMonitoring

    case .authenticator:
      self = .authenticator

    case .otherTool(.contacts):
      self = .contacts

    case .otherTool(.vpn):
      self = .secureWifi

    case .otherTool(.generator), .otherTool(.history):
      self = .passwordGenerator

    case .otherTool(.tools):
      return nil
    case .unresolvedAlert:
      return nil
    }

  }
}
