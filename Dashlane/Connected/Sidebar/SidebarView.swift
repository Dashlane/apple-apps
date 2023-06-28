import CoreFeature
import CoreLocalization
import CorePersonalData
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

    @FeatureState(.collectionsContainer)
    private var areCollectionsEnabled

    var body: some View {
        List(selection: $model.selection) {
            SidebarLabel(CoreLocalization.L10n.Core.mainMenuHomePage,
                         image: .ds.home.outlined,
                         selectedImage: .ds.home.filled,
                         isSelected: model.selection == .home)
            .select(NavigationItem.home, selection: $model.selection)

            Group {
                SidebarLabel(L10n.Localizable.tabNotificationsTitle,
                             image: .ds.notification.outlined,
                             selectedImage: .ds.notification.filled,
                             isSelected: model.selection == .notifications)
                .badge(badgeValue(for: .notifications))
                .fiberAccessibilityLabel(Text(L10n.Localizable.tabNotificationsTitle))
                .fiberAccessibilityElement(children: .combine)
                .select(NavigationItem.notifications, selection: $model.selection)
                vaultSection
                toolsSection
                if areCollectionsEnabled {
                    collectionsSection
                }
            }
            .foregroundColor(.ds.text.neutral.quiet)
        }
        .listStyle(.sidebar)
        .sheet(isPresented: $model.settingsDisplayed) {
            SettingsFlowView(viewModel: model.settingsFlowViewModelFactory.make())
        }
        .toolbar {
            Button {
                model.settingsDisplayed = true
            } label: {
                Image.ds.settings.outlined
            }
            .accessibilityLabel(L10n.Localizable.tabSettingsTitle)
            .buttonStyle(.colored(Color.ds.text.brand.standard)) 
        }
        .tint(.ds.text.neutral.quiet)
        .mainMenuShortcut(.preferences,
                          enabled: true,
                          action: {
            self.model.deeplinkingService.handleLink(.settings(.root))
        })
    }

        var vaultSection: some View {
        Section(L10n.Localizable.tabVaultTitle) {
            ForEach(ItemCategory.allCases) { category in
                let categorySelection = NavigationItem.vault(category)
                SidebarLabel(category, isSelected: model.selection == categorySelection)
                    .badge(badgeValue(for: categorySelection))
                    .fiberAccessibilityElement(children: .combine)
                    .fiberAccessibilityLabel(Text(category.title))
                    .select(categorySelection, selection: $model.selection)
            }

            SidebarLabel(ToolsItem.contacts, isSelected: model.selection == .tools(.contacts))
                .select(NavigationItem.tools(.contacts), selection: $model.selection)
        }
    }

    var toolsSection: some View {
        Section(L10n.Localizable.sidebarToolsTitle) {
            ForEach(model.tools) { tool in
                let toolSelection = NavigationItem.tools(tool.item)

                HStack {
                    SidebarLabel(tool.item, isSelected: model.selection == toolSelection)
                    Spacer()
                    if let status = tool.badgeStatus {
                        FeatureBadge(status)
                            .style(mood: Device.isMac ? .neutral : .brand, intensity: .quiet)

                    }
                }
                .select(toolSelection, selection: $model.selection)

            }
        }
    }

    var collectionsSection: some View {
        Section(header: CollectionsSidebarSectionHeader(collectionNamingViewModelFactory: model.collectionNamingViewModelFactory)) {
            ForEach(model.collections.sortedByName(), id: \.id) { collection in
                let collectionSelection = NavigationItem.collection(.init(collection: collection))

                HStack {
                    SidebarLabel(collection.name, isSelected: model.selection == collectionSelection)

                    if let space = model.space(for: collection) {
                        UserSpaceIcon(space: space, size: .small)
                    }

                    if collection.isShared {
                        Image.ds.shared.outlined
                            .resizable()
                            .frame(width: sharedIconSize, height: sharedIconSize)
                            .foregroundColor(.ds.text.neutral.quiet)
                    }
                }
                                .badge(Text("\(collection.items.count)"))
                .fiberAccessibilityElement(children: .combine)
                .fiberAccessibilityLabel(Text(collection.name))
                .select(collectionSelection, selection: $model.selection)
            }
        }
    }

    @ViewBuilder
    func badgeValue(for item: NavigationItem) -> Text? {
        if let badgeValue = model.badgeValues[item] {
            Text(badgeValue)

        }
    }
}

private struct SidebarLabel: View {
    init(_ title: String, image: Image?, selectedImage: Image?, isSelected: Bool) {
        self.title = title
        self.image = image
        self.selectedImage = selectedImage
        self.isSelected = isSelected
    }

    let title: String
    let image: Image?
    let selectedImage: Image?
    let isSelected: Bool

    @ViewBuilder
    var imageForSelection: some View {
        if isSelected {
            selectedImage
                .transition(.asymmetric(insertion: .scale(scale: 0.8), removal: .identity))
        } else {
            image
                .transition(.identity)
        }
    }

    var body: some View {
        HStack {
            imageForSelection
                .foregroundColor(.ds.text.brand.standard)

            Text(title)
                .accessibilityTextContentType(.plain)
                .foregroundColor(.ds.text.neutral.standard)
        }
        .animation(.easeOut(duration: 0.3), value: isSelected)
        .fiberAccessibilityElement(children: .combine)
    }
}

private protocol SidebarItem {
    var title: String { get }
    var icon: Image { get }
    var selectedIcon: Image { get }
}

extension ItemCategory: SidebarItem { }
extension ToolsItem: SidebarItem { }

extension SidebarLabel {
    init(_ item: SidebarItem, isSelected: Bool) {
        self.init(item.title,
                  image: item.icon,
                  selectedImage: item.selectedIcon,
                  isSelected: isSelected)
    }

    init(_ title: String, isSelected: Bool) {
        self.init(title, image: nil, selectedImage: nil, isSelected: isSelected)
    }
}

fileprivate extension View {
        @ViewBuilder
    func select(_ select: NavigationItem, selection: Binding<NavigationItem?>) -> some View {
        self.tag(select)
            .listRowBackground(Group {
                if selection.wrappedValue == select {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .foregroundColor(.primary.opacity(0.07))
                }
            })
    }
}

struct SidebarView_Previews: PreviewProvider {
    static var previews: some View {
        let model = SidebarViewModel(
            toolsService: .mock(capabilities: .init(secureWiFi: .init(enabled: false, info: .init(reason: .team)))),
            teamSpacesService: MockServicesContainer().teamSpacesService,
            vaultItemsService: MockServicesContainer().vaultItemsService,
            deeplinkingService: DeepLinkingService.fakeService,
            settingsFlowViewModelFactory: .init { .mock },
            collectionNamingViewModelFactory: .init { _ in .mock(mode: .addition) }
        )
        NavigationSplitView {
            SidebarView(model: model)
        } detail: {
            Text("Hello, World!d")
        }
        .previewInterfaceOrientation(.landscapeLeft)
        .previewDisplayName("Embed in swiftui nav")

        EmbeddedViewController {
            let splitViewController = UISplitViewController(style: .doubleColumn)
            splitViewController.primaryBackgroundStyle = .sidebar
            splitViewController.preferredDisplayMode = .oneBesideSecondary
            splitViewController.view.backgroundColor = .ds.background.alternate

            splitViewController.setViewController(SidebarHostingViewController(model: model), for: .primary)
            splitViewController.setViewController(UIHostingController(rootView: ZStack {
                Text("Hello, World!d")
            }), for: .secondary)

            return splitViewController
        }
        .previewInterfaceOrientation(.landscapeLeft)
        .previewDisplayName("Embed in uiviewcontroller nav")

    }
}
