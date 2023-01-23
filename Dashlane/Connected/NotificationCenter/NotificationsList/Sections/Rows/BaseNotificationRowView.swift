import SwiftUI
import UIDelight

struct BaseNotificationRowView: View {
    let icon: Image
    let iconBackgroundColor: Color
    let title: String
    let description: String
    let reportClick: () -> Void
    let onTap: () -> Void

    init(icon: Image,
         iconBackgroundColor: Color = Color(asset: FiberAsset.midGreen),
         title: String,
         description: String,
         reportClick: @escaping () -> Void,
         onTap: @escaping () -> Void) {
        self.icon = icon
        self.iconBackgroundColor = iconBackgroundColor
        self.title = title
        self.description = description
        self.reportClick = reportClick
        self.onTap = onTap
    }

    var body: some View {
        HStack(alignment: .top) {
            icon
                .frame(width: 24, height: 24)
                .foregroundColor(Color.white)
                .padding(10)
                .background(iconBackgroundColor)
                .cornerRadius(22)

            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .foregroundColor(Color(asset: FiberAsset.settingsPrimaryHighlight))
                    .font(.body.weight(.medium))
                    .fixedSize(horizontal: false, vertical: true)

                Text(description)
                    .foregroundColor(Color(asset: FiberAsset.settingsSecondaryHighlight))
                    .font(.subheadline)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .multilineTextAlignment(.leading)
        .padding(.vertical, 15)
        .onTapWithFeedback {
            reportClick()
            onTap()
        }
    }
}

struct BaseNotificationRowView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            BaseNotificationRowView(icon: Image(asset: FiberAsset.resetMasterPasswordActionItemIcon),
                                    title: "My notification",
                                    description: "This is a dummy notification. You will never forget it",
                                    reportClick: {},
                                    onTap: {})
        }
    }
}
