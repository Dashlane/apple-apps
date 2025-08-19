import SwiftUI

struct SecurityAlertNotificationRowView: View {
  let model: SecurityAlertNotificationRowViewModel

  @State
  private var showAlertViewController = false

  var body: some View {
    BaseNotificationRowView(
      icon: model.notification.icon,
      title: model.notification.title,
      description: model.notification.description,
      notificationState: model.notification.state
    ) { self.model.openUnresolvedAlert() }
  }
}

struct SecurityAlertNotificationRowView_Previews: PreviewProvider {
  static var previews: some View {
    List {
      SecurityAlertNotificationRowView(model: .mock)
    }
  }
}
