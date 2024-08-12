import SwiftTreats
import SwiftUI
import UIComponents
import UIDelight

struct NotificationSectionView: View {
  let model: NotificationSectionViewModel
  let showAll: () -> Void

  var body: some View {
    Section(content: content, header: header)
  }

  @ViewBuilder
  func content() -> some View {
    ForEach(model.displayableNotifications, id: \.id) { notification in
      notificationView(notification)
        .onFirstDisappear {
          notification.notificationActionHandler.reportAsDisplayed()
        }
        .listRowBackground(rowBackground(for: notification))
    }.onDelete(perform: deleteItems)
  }

  @ViewBuilder
  private func notificationView(_ notification: DashlaneNotification) -> some View {
    switch notification.kind {
    case .static(let kind):
      switch kind {
      case .secureLock:
        SecureLockNotificationRowView(model: model.secureLockPasswordViewModel(notification))
      case .trialPeriod:
        TrialPeriodNotificationRowView(model: model.trialPeriodViewModel(notification))
      case .resetMasterPassword:
        ResetMasterPasswordNotificationRowView(
          model: model.resetMasterPasswordViewModel(notification))
      }
    case .dynamic(let kind):
      switch kind {
      case .sharing:
        SharingRequestNotificationRowView(model: model.sharingItemViewModel(notification))
      case .securityAlert:
        SecurityAlertNotificationRowView(model: model.securityAlertViewModel(notification))
      }
    }
  }

  @ViewBuilder
  private func header() -> some View {
    if model.shouldShowHeader {
      HStack {
        Text(model.dataSection.category.sectionTitle)
          .font(.custom(GTWalsheimPro.medium.name, size: 20, relativeTo: .title3))
          .foregroundColor(Color.primary)

        Spacer()

        seeAllButton
      }
      .textCase(nil)
    }
  }

  @ViewBuilder
  private var seeAllButton: some View {
    if model.isTruncated && model.dataSection.notifications.count > 2 {
      Button {
        showAll()
      } label: {
        Text(L10n.Localizable.notificationCenterSeeAll(model.dataSection.notifications.count))
          .foregroundColor(.ds.text.brand.standard)
          .font(.subheadline)
      }
      .fiberAccessibilityLabel(
        Text(
          L10n.Localizable.notificationCenterSeeAll(model.dataSection.notifications.count)
            + " \(model.dataSection.category.sectionTitle) \(L10n.Localizable.tabNotificationsTitle)"
        ))
    }
  }

  private func rowBackground(for notification: DashlaneNotification) -> Color {
    if notification.state == .unseen {
      return .ds.container.expressive.brand.quiet.idle
    } else {
      return .ds.container.agnostic.neutral.supershy
    }
  }

  private func deleteItems(at indexSet: IndexSet) {
    let notifications = indexSet.map { model.dataSection.notifications[$0] }
    notifications.forEach {
      $0.dismissAction()
      $0.notificationActionHandler.dismiss()
    }
  }
}

struct NotificationSectionView_Previews: PreviewProvider {
  static var previews: some View {
    MultiContextPreview {
      List {
        NotificationSectionView(model: .mock) {

        }
      }
    }
  }
}
