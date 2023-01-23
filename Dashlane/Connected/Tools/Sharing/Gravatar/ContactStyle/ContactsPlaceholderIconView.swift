import DesignSystem
import SwiftUI
import UIDelight

struct ContactsPlaceholderIconView: View {
    let title: String
    let isLarge: Bool

    let backgroundColor: Color

    init(title: String, isLarge: Bool, backgroundColor: Color? = nil) {
        self.title = String(title.prefix(2)).uppercased()
        self.isLarge = isLarge
        self.backgroundColor = backgroundColor ?? Color.contactPlaceholderColor(forTitle: title)
    }

    var body: some View {
        Text(title)
            .accessibilityHidden(true)
            .foregroundColor(.ds.text.neutral.catchy)
            .font(.system(size: isLarge ? 32 : 20.5, weight: .bold, design: .default))
            .contactsIconStyle(isLarge: isLarge, backgroundColor: backgroundColor)
    }
}

struct ContactsPlaceholderIconView_Previews: PreviewProvider {
    static var previews: some View {
        MultiContextPreview {
            ContactsPlaceholderIconView(title: "dashlane", isLarge: true)
            ContactsPlaceholderIconView(title: "Facebook", isLarge: false)
        }
        .padding()
        .previewLayout(.sizeThatFits)

    }
}

extension Color {
    static let backgroundColors: [Color] = [FiberAsset.contactsBlue,
                                            FiberAsset.contactsOrange,
                                            FiberAsset.contactsPurple,
                                            FiberAsset.contactsYellow,
                                            FiberAsset.contactsTurquoise,
                                            FiberAsset.contactsViolet].map { .init(asset: $0) }

    static func contactPlaceholderColor(forTitle title: String) -> Color {
        let index = abs(title.hash % backgroundColors.count)
        return backgroundColors[index]
    }
}
