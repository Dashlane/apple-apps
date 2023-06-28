import SwiftUI

struct MainTabView<Tab: TabViewElement>: View {
    
    let tabs: [Tab]
    
    @Binding
    var selectedTab: Tab
    
    @State
    private var maximumCellHeight: CGFloat = 0
    

    init(initial: Binding<Tab>, tabs: [Tab]) {
        self.tabs = tabs
        _selectedTab = initial
    }
    
    var body: some View {
        GeometryReader { reader in
            HStack(spacing: 0) {
                ForEach(tabs.indices, id: \.self) { index in
                    content(for: tabs[index], proxy: reader)
                    if index < (tabs.count - 1) {
                        separator
                            .accessibilityHidden(true)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 80)
    }
    
    private func content(for tab: Tab, proxy: GeometryProxy) -> some View {
        Button(action: {
            self.selectedTab = tab
        }, label: {
            VStack(spacing: 8) {
                titleAndImage(for: tab, tabWidth: proxy.size.width * tab.distributedSizePercentage / 100)
                    .onSizeChange(onTitleSizeChange)
                .frame(height: maximumCellHeight)
                selectedIndicator(for: tab)
            }
            .frame(width: proxy.size.width * tab.distributedSizePercentage / 100)
            .frame(maxHeight: .infinity)
            .contentShape(Rectangle())
        })
        .disabled(selectedTab == tab)
        .disabled(!tab.isActive)
        .buttonStyle(TabButtonStyle(isSelected: selectedTab == tab, isActive: tab.isActive))
        .accessibilityLabel(Text(accessibilityLabel(for: tab)))
        .accessibilityRemoveTraits(.isButton)
    }

    func accessibilityLabel(for tab: Tab) -> String {
        let base = L10n.Localizable.accessibilityTraitTab(tab.title ?? L10n.Localizable.settingsTitle)
        if selectedTab == tab {
            return L10n.Localizable.accessibilityVaultFilterItemSelected(base)
        } else {
            return base
        }
    }

    private func titleAndImage(for tab: Tab, tabWidth: CGFloat) -> some View {
        VStack(alignment: .center, spacing: 0) {
            tab.image.swiftUIImage
                .resizable()
                .frame(width: 20, height: 20)
            if let title = tab.title {
                Text(title)
                    .font(.system(size: 12))
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: tabWidth, maxHeight: .infinity)
            }
        }
    }
    
    private var separator: some View {
        Image(asset: Asset.tabSeparator)
            .foregroundColor(Color(asset: Asset.dashGreenCopy))
    }
    
    @ViewBuilder
    func selectedIndicator(for tab: Tab) -> some View {
        if tab == selectedTab {
            Image(asset: Asset.tabSelectedIndicator)
        } else {
            Image(asset: Asset.tabSelectedIndicator).hidden()
        }
    }
    
    private func onTitleSizeChange(_ size: CGSize) {
        guard size.height != 0 else {
            return
        }
        if size.height > maximumCellHeight {
            maximumCellHeight = size.height
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    
    struct TabViewElementMock: TabViewElement {
        let id = UUID()
        let title: String?
        let image: ImageAsset
        let distributedSizePercentage: CGFloat
        var isActive: Bool = true
        
        static func == (lhs: TabViewElementMock, rhs: TabViewElementMock) -> Bool {
            lhs.id == rhs.id
        }
    }

        struct MainTabViewPreviewContainer : View {
        @State
        private var value: TabViewElementMock
        
        let tabs: [TabViewElementMock]
        
        init() {
            
            let firstTab = TabViewElementMock(title: "First tab",
                                              image: Asset.tabVault,
                                              distributedSizePercentage: 25)
            let secondTab = TabViewElementMock(title: "Second tab",
                                              image: Asset.tabVault,
                                              distributedSizePercentage: 25,
                                              isActive: false)
            let thirdTab = TabViewElementMock(title: "Third tab",
                                              image: Asset.tabPasswordGenerator,
                                              distributedSizePercentage: 35)
            let fourthTab = TabViewElementMock(title: nil,
                                               image: Asset.tabSettings,
                                              distributedSizePercentage: 15)
            
            _value = State(initialValue: firstTab)
            self.tabs = [
                firstTab, secondTab, thirdTab, fourthTab
            ]
        }
        
        var body: some View {
            MainTabView<TabViewElementMock>(initial: $value, tabs: tabs)
        }
    }
    
    static var previews: some View {
        PopoverPreviewScheme {
            MainTabViewPreviewContainer().frame(width: 400)
        }
    }
}
