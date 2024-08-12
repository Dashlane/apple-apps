import DesignSystem
import SwiftUI
import UIDelight

struct BaseNotificationRowView: View {
  let icon: Image
  let iconBackgroundColor: Color
  let title: String
  let description: String
  let accessibilityDescription: String?
  let onTap: () -> Void

  init(
    icon: Image,
    iconBackgroundColor: Color = .ds.text.brand.quiet,
    title: String,
    description: String,
    accessibilityDescription: String? = nil,
    onTap: @escaping () -> Void
  ) {
    self.icon = icon
    self.iconBackgroundColor = iconBackgroundColor
    self.title = title
    self.description = description
    self.accessibilityDescription = accessibilityDescription
    self.onTap = onTap
  }

  var body: some View {
    HStack(alignment: .top, spacing: 16) {
      icon
        .frame(width: 24, height: 24)
        .foregroundColor(Color.white)
        .padding(10)
        .background(iconBackgroundColor)
        .cornerRadius(22)

      VStack(alignment: .leading, spacing: 8) {
        Text(title)
          .foregroundColor(.ds.text.neutral.standard)
          .textStyle(.title.block.medium)
          .fixedSize(horizontal: false, vertical: true)
        Text(description)
          .textStyle(.body.reduced.regular)
          .foregroundColor(.ds.text.neutral.standard)
          .fixedSize(horizontal: false, vertical: true)
          .accessibilityLabel(accessibilityDescriptionLabel)
      }
    }
    .multilineTextAlignment(.leading)
    .padding(.vertical, 15)
    .onTapWithFeedback {
      onTap()
    }
  }

  private var accessibilityDescriptionLabel: String {
    accessibilityDescription ?? description
  }
}

struct BaseNotificationRowView_Previews: PreviewProvider {
  static var previews: some View {
    List {
      BaseNotificationRowView(
        icon: Image(asset: FiberAsset.resetMasterPasswordActionItemIcon),
        title: "My notification",
        description: "This is a dummy notification. You will never forget it",
        onTap: {}
      )
    }
  }
}
