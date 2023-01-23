import Foundation
import SwiftUI
import DesignSystem

struct SharingToolRecipientRow<Icon: View>: View {
    let title: String
    let subtitle: String?
    let icon: Icon

    init(title: String, subtitle: String?, @ViewBuilder icon: () -> Icon) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon()
    }

    init(title: String, itemsCount: Int, @ViewBuilder icon: () -> Icon) {
        self.title = title
        self.subtitle = L10n.Localizable.rowItemsSubtitle(forCount: itemsCount)
        self.icon = icon()
    }

    init(title: String, usersCount: Int, @ViewBuilder icon: () -> Icon) {
        self.title = title
        self.subtitle = L10n.Localizable.rowUsersSubtitle(forCount: usersCount)
        self.icon = icon()
    }

    var body: some View {
        HStack(spacing: 16) {
            icon
                .contactsIconStyle(isLarge: false)
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.body)
                    .foregroundColor(.ds.text.neutral.catchy)
                    .lineLimit(1)
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.ds.text.neutral.quiet)
                }
            }.frame(maxWidth: .infinity, alignment: .leading)
        }
        .contentShape(Rectangle())
        .padding(.vertical, 5)
    }
}

private extension L10n.Localizable {
    static func rowItemsSubtitle(forCount count: Int) -> String {
        let subtitle = count > 1 ? L10n.Localizable.kwItemsShared : L10n.Localizable.kwItemShared
        let finalSubtitle = "\(count)" + " " + subtitle
        return finalSubtitle
    }

    static func rowUsersSubtitle(forCount count: Int) -> String {
        return count > 1 ? L10n.Localizable.kwSharingUsersPlural(count) : L10n.Localizable.kwSharingUsersSingular(count)
    }
}
