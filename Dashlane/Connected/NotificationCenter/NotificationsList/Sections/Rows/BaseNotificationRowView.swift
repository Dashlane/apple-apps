import DesignSystem
import SwiftUI
import UIDelight

struct BaseNotificationRowView: View {
  let icon: Image
  let title: String
  let description: String
  let accessibilityDescription: String?
  let notificationState: NotificationCenterService.Notification.State
  let onTap: () -> Void

  init(
    icon: Image,
    title: String,
    description: String,
    accessibilityDescription: String? = nil,
    notificationState: NotificationCenterService.Notification.State,
    onTap: @escaping () -> Void
  ) {
    self.icon = icon
    self.title = title
    self.description = description
    self.accessibilityDescription = accessibilityDescription
    self.notificationState = notificationState
    self.onTap = onTap
  }

  var body: some View {
    HStack(alignment: .center, spacing: 12) {
      HStack(alignment: .top, spacing: 12) {
        DS.ExpressiveIcon(icon)
          .style(mood: .brand, intensity: .quiet)
          .controlSize(.regular)

        VStack(alignment: .leading, spacing: 4) {
          Text(title)
            .foregroundStyle(Color.ds.text.neutral.catchy)
            .textStyle(.title.block.medium)
          Text(description)
            .foregroundStyle(Color.ds.text.neutral.standard)
            .textStyle(.body.reduced.regular)
            .accessibilityLabel(accessibilityDescriptionLabel)
        }

        Spacer()
      }

      if notificationState == .unseen {
        Circle()
          .fill(Color.red)
          .frame(width: 8)
      }
    }
    .listRowInsets(.init(top: 8, leading: 16, bottom: 8, trailing: 16))
    .multilineTextAlignment(.leading)
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
        icon: Image.ds.feature.autofill.outlined,
        title: "My notification",
        description: "This is a dummy notification. You will never forget it",
        notificationState: .unseen, onTap: {}
      )
    }
    .listStyle(.ds.insetGrouped)
  }
}
