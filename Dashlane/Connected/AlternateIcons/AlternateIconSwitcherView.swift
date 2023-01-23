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
        VStack(alignment: .leading) {
            Text(L10n.Localizable.alternateIconViewTitle)
                .font(.body)
                .bold()
                .foregroundColor(Color.primary)
                .padding(.top, 32)
                .padding(.bottom, 16)
                .padding(.horizontal, 28)
            LazyVGrid(columns: columns) {
                ForEach(0..<iconSettings.iconNames.count, id: \.self) { index in
                    iconRow(forIndex: index, isSelected: self.iconSettings.currentIndex == index)
                }
            }.padding(.horizontal, 28)

            Spacer()
        }
        .navigationTitle(L10n.Localizable.alternateIconSettingsTitle)
        .backgroundColorIgnoringSafeArea(Color(asset: FiberAsset.appBackground))
    }

    @ViewBuilder
    func iconRow(forIndex index: Int, isSelected: Bool) -> some View {
        ZStack {
            Image(uiImage: UIImage(named: self.iconSettings.iconNames[index] ?? "AppIconAlternate") ?? UIImage())
                .resizable()
                .renderingMode(.original)
                .frame(width: 60, height: 60)
                .cornerRadius(15)
                .overlay(RoundedRectangle(cornerRadius: 15)
                            .stroke(Color(asset: FiberAsset.alternateIconBorder), lineWidth: 0.5))
                .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
            Image(asset: FiberAsset.iconSelection)
                .resizable()
                .frame(width: 24, height: 24, alignment: .center)
                .padding(.top, 56)
                .padding(.leading, 56)
                .opacity(isSelected ? 1 : 0)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            self.iconSettings.changeIcon(toIndex: index)
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
