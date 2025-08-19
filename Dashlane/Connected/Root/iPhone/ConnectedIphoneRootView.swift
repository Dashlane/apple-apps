import CoreLocalization
import SwiftUI
import UIDelight

@ViewInit
struct ConnectedIphoneRootView: View {
  @StateObject
  var model: ConnectedIphoneRootViewModel

  @State private
    var selection: NavigationItem = .home

  var body: some View {
    TabView(selection: $selection) {
      NavigationView {
        HomeFlow(viewModel: self.model.homeFlowViewModelFactory.make())
      }
      .navigationViewStyle(.stack)
      .tabLabel(
        CoreL10n.mainMenuHomePage,
        image: .ds.home.outlined,
        selectedImage: .ds.home.filled,
        item: .home,
        selection: selection)

      NavigationView {
        NotificationsFlow(viewModel: self.model.notificationViewModelFactory.make())
      }
      .navigationViewStyle(.stack)
      .tabLabel(
        L10n.Localizable.tabNotificationsTitle,
        image: .ds.notification.outlined,
        selectedImage: .ds.notification.filled,
        item: .notifications,
        selection: selection)

      NavigationView {
        PasswordGeneratorToolsFlow(
          viewModel: model.passwordGeneratorToolsFlowViewModelFactory.make())
      }
      .navigationViewStyle(.stack)
      .tabLabel(
        CoreL10n.tabGeneratorTitle,
        image: .ds.feature.passwordGenerator.outlined,
        selectedImage: .ds.feature.passwordGenerator.filled,
        item: .tools(.passwordGenerator),
        selection: selection)

      NavigationView {
        ToolsFlow(viewModel: model.toolsFlowViewModelFactory.make(toolsItem: nil))
      }
      .navigationViewStyle(.stack)
      .tabLabel(
        L10n.Localizable.tabToolsTitle,
        image: .ds.tools.outlined,
        selectedImage: .ds.tools.filled,
        item: .tools(nil),
        selection: selection)

      SettingsFlowView(viewModel: model.settingsFlowViewModelFactory.make())
        .tabLabel(
          L10n.Localizable.tabSettingsTitle,
          image: .ds.settings.outlined,
          selectedImage: .ds.settings.filled,
          item: .settings,
          selection: selection)
    }
    .onReceive(model.deepLinkPublisher, perform: handle)
    .toasterOn()
  }

  func handle(_ deepLink: DeepLink) {
    switch deepLink {
    case .prefilledCredential,
      .search,
      .importMethod,
      .other(.dashboard, _):
      selection = .home

    case .notifications:
      selection = .notifications

    case .tool(let toolDeeplink, _):
      switch toolDeeplink {
      case .otherTool(.generator), .otherTool(.history):
        selection = .tools(.passwordGenerator)
        return

      default:
        selection = .tools(nil)
      }

    case .settings, .mplessLogin:
      selection = .settings

    case .other(.contacts, _), .other(.sharing, _):
      selection = .tools(nil)

    case .unresolvedAlert:
      selection = .notifications

    default: break

    }
  }
}

extension View {
  fileprivate func tabLabel(
    _ title: String,
    image: Image,
    selectedImage: Image,
    item: NavigationItem,
    selection: NavigationItem
  ) -> some View {
    self.tabItem {
      let isSelected = item == selection
      Label(
        title: {
          Text(title)
        },
        icon: {
          if isSelected {
            selectedImage
          } else {
            image
          }
        }
      )
    }
    .tag(item)
  }
}
