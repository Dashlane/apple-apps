import DesignSystem
import SwiftUI
import UIDelight

struct AlternateIconSwitcherView: View {

    @ObservedObject private var iconSettings: AlternateIconNames

    private var columns: [GridItem] = Array(repeating: .init(.flexible(), spacing: 26),
                                            count: 4)

    public init(iconSettings: AlternateIconNames) {
        self.iconSettings = iconSettings
    }

    var body: some View {
        LazyVGrid(columns: columns) {
            ForEach(iconSettings.icons, id: \.name) { icon in
                row(icon, isSelected: iconSettings.currentIcon == icon)
            }
        }
        .padding(.horizontal, 28)
        .frame(maxHeight: .infinity, alignment: .top)
        .navigationTitle(L10n.Localizable.alternateIconSettingsTitle)
        .backgroundColorIgnoringSafeArea(.ds.background.default)
        .animation(.default, value: iconSettings.currentIcon)
    }

    @ViewBuilder
    func row(_ icon: AlternateIconNames.Icon, isSelected: Bool) -> some View {
        Image(uiImage: UIImage(named: icon.name)!)
            .resizable()
            .renderingMode(.original)
            .frame(width: 60, height: 60)
            .cornerRadius(15)
            .overlay(RoundedRectangle(cornerRadius: 15)
                .stroke(Color.ds.border.neutral.standard.idle, lineWidth: 0.5))
            .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
            .padding(8)
            .overlay(alignment: .bottomTrailing) {
                selectedIcon
                    .opacity(isSelected ? 1 : 0)
            }
            .onTapGesture {
                self.iconSettings.changeIcon(to: icon)
            }
    }

    var selectedIcon: some View {
        Circle()
            .foregroundColor(Color.ds.container.expressive.positive.catchy.active)
            .frame(width: 24, height: 24, alignment: .center)
            .overlay {
                Image.ds.checkmark.outlined
                    .renderingMode(.template)
                    .resizable()
                    .foregroundColor(.ds.text.inverse.catchy)
                    .padding(4)
            }

    }
}

struct AlternateIconSwitcherView_Previews: PreviewProvider {
    static var previews: some View {
        MultiContextPreview {
            AlternateIconSwitcherView(iconSettings: AlternateIconNames(categories: [.brand, .pride]))
        }
    }
}
