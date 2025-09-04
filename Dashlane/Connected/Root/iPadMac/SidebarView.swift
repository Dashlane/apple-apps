import CoreFeature
import CoreLocalization
import CorePersonalData
import CorePremium
import DesignSystem
import SwiftTreats
import SwiftUI
import UIComponents
import UIDelight
import VaultKit

struct SidebarView: View {

  @ObservedObject
  var model: SidebarViewModel

  @ScaledMetric
  private var sharedIconSize: CGFloat = 12

  @CapabilityState(.secretManagement)
  var secretManagementStatus

  @FeatureState(.wifiCredential)
  var isWiFiCredentialEnabled

  @Environment(\.toast)
  var toast

  var body: some View {
    List(selection: $model.selection) {
      Section {
        SidebarLabel(CoreL10n.mainMenuHomePage, image: .ds.home.outlined)
          .tag(NavigationItem.home)

        SidebarLabel(L10n.Localizable.tabNotificationsTitle, image: .ds.notification.outlined)
          .badge(badgeValue(for: .notifications))
          .fiberAccessibilityLabel(Text(L10n.Localizable.tabNotificationsTitle))
          .fiberAccessibilityElement(children: .combine)
          .tag(NavigationItem.notifications)
      }

      Group {
        vaultSection
        toolsSection
        collectionsSection
      }
    }
    .listStyle(.sidebar)
    #if targetEnvironment(macCatalyst)
      .transparentSidebar()
    #endif
    .sheet(isPresented: $model.settingsDisplayed) {
      SettingsFlowView(viewModel: model.settingsFlowViewModelFactory.make())
    }
    .sheet(isPresented: $model.showCollectionAddition) {
      CollectionNamingView(viewModel: model.collectionNamingViewModelFactory.make(mode: .addition))
      { _ in
        model.showCollectionAddition = false
      }
    }
    .toolbar {
      Button {
        model.settingsDisplayed = true
      } label: {
        Image.ds.settings.outlined
      }
      .accessibilityLabel(L10n.Localizable.tabSettingsTitle)
    }
    .mainMenuShortcut(
      .preferences,
      enabled: true,
      action: {
        self.model.handleLink(.settings(.root))
      })

  }

  var vaultSection: some View {
    Section(L10n.Localizable.tabVaultTitle) {
      ForEach(itemCategories) { category in
        let categorySelection = NavigationItem.vault(category)
        SidebarLabel(category)
          .badge(badgeValue(for: categorySelection))
          .fiberAccessibilityElement(children: .combine)
          .fiberAccessibilityLabel(Text(category.title))
          .tag(categorySelection)

      }

      SidebarLabel(ToolsItem.contacts)
        .tag(NavigationItem.tools(.contacts))
    }
  }

  var toolsSection: some View {
    Section(L10n.Localizable.sidebarToolsTitle) {
      ForEach(model.tools) { tool in
        let toolSelection = NavigationItem.tools(tool.item)
        HStack {
          SidebarLabel(tool.item)
          Spacer()
          if let status = tool.badgeStatus {
            FeatureBadge(status)
              .style(mood: Device.is(.mac) ? .neutral : .brand, intensity: .quiet)
          }
        }
        .tag(toolSelection)

      }
    }
  }

  var collectionsSection: some View {
    Section(
      header: CollectionsSidebarSectionHeader(
        collectionNamingViewModelFactory: model.collectionNamingViewModelFactory,
        showCollectionAddition: $model.showCollectionAddition)
    ) {
      ForEach(model.collections, id: \.id) { collection in
        let collectionSelection = NavigationItem.collection(.init(collection: collection))
        HStack {
          SidebarLabel(collection.name)

          if let space = model.space(for: collection) {
            UserSpaceIcon(space: space, size: .small)
          }

          if collection.isShared {
            Image.ds.shared.outlined
              .resizable()
              .frame(width: sharedIconSize, height: sharedIconSize)
              .foregroundStyle(Color.ds.text.neutral.quiet)
          }
        }
        .badge(Text("\(collection.itemIds.count)"))
        .fiberAccessibilityElement(children: .combine)
        .fiberAccessibilityLabel(Text(collection.name))
        .droppableDestination(for: Credential.self) { items, _ in
          model.add(items, to: collection, with: toast)
          return true
        }
        .confirmationDialog(
          confirmationDialogTitle,
          isPresented: $model.showSharedCollectionDialog,
          titleVisibility: .visible,
          presenting: model.itemsCollectionAddition,
          actions: { itemsCollectionAddition in
            Button(CoreL10n.KWVaultItem.Collections.Sharing.AdditionAlert.button) {
              model.confirmAddition(
                of: itemsCollectionAddition.items,
                to: itemsCollectionAddition.collection,
                with: toast
              )
            }
          },
          message: { itemsCollectionAddition in
            confirmationDialogMessage(
              items: itemsCollectionAddition.items,
              collection: itemsCollectionAddition.collection
            )
          }
        )
        .tag(collectionSelection)
      }
    }
  }

  @ViewBuilder
  func badgeValue(for item: NavigationItem) -> Text? {
    if let badgeValue = model.badgeValues[item], badgeValue > 0 {
      Text(String(badgeValue))
    }
  }

  private var itemCategories: [ItemCategory] {
    ItemCategory.allCases.lazy
      .filter { category in
        switch category {
        case .secrets:
          return secretManagementStatus.isAvailable
        case .wifi:
          return isWiFiCredentialEnabled
        default:
          return true
        }
      }
  }

  private var confirmationDialogTitle: String {
    if (model.itemsCollectionAddition?.items.count ?? 0) > 1 {
      return CoreL10n.KWVaultItem.Collections.Sharing.AdditionAlert.Title.plural
    } else if let item = model.itemsCollectionAddition?.items.first {
      return CoreL10n.KWVaultItem.Collections.Sharing.AdditionAlert.title(item.localizedTitle)
    } else {
      return ""
    }
  }

  private func confirmationDialogMessage(items: [VaultItem], collection: VaultCollection)
    -> some View
  {
    if items.count > 1 {
      return Text(
        CoreL10n.KWVaultItem.Collections.Sharing.AdditionAlert.Message.plural(collection.name))
    } else {
      return Text(CoreL10n.KWVaultItem.Collections.Sharing.AdditionAlert.message(collection.name))
    }
  }
}

private struct SidebarLabel: View {
  init(_ title: String, image: Image? = nil) {
    self.title = title
    self.image = image
  }

  let title: String
  let image: Image?

  var body: some View {
    Label {
      Text(title)
    } icon: {
      image
    }.lineLimit(1)
  }
}

private protocol SidebarItem {
  var title: String { get }
  var icon: Image { get }
}

extension ItemCategory: SidebarItem {}
extension ToolsItem: SidebarItem {}

extension SidebarLabel {
  init(_ item: SidebarItem) {
    self.init(item.title, image: item.icon)
  }
}

struct SidebarView_Previews: PreviewProvider {
  static var previews: some View {
    let model = SidebarViewModel(
      featureService: .mock(),
      premiumStatusServicesSuit: .mock,
      userSpacesService: MockServicesContainer().userSpacesService,
      vaultCollectionsStore: MockVaultKitServicesContainer().vaultCollectionsStore,
      deeplinkingService: DeepLinkingService.fakeService,
      settingsFlowViewModelFactory: .init { .mock },
      collectionNamingViewModelFactory: .init { _ in .mock(mode: .addition) },
      vaultCollectionEditionServiceFactory: .init { .mock($0) }
    )
    NavigationSplitView {
      SidebarView(model: model)
    } detail: {
      Text("Hello, World!d")
    }
    .previewInterfaceOrientation(.landscapeLeft)
    .previewDisplayName("Embed in swiftui nav")
  }
}
