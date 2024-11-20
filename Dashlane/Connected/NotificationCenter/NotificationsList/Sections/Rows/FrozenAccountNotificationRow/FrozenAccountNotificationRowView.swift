import SwiftUI
import UIDelight

struct FrozenAccountNotificationRowView: View {
  let model: FrozenAccountNotificationRowViewModel

  @State
  private var showAlertViewController = false

  var body: some View {
    BaseNotificationRowView(
      icon: model.notification.icon,
      iconBackgroundColor: Color.red,
      title: model.notification.title,
      description: model.notification.description
    ) {
      self.model.showPaywall()
    }
  }
}

struct FrozenAccountNotificationRowView_Previews: PreviewProvider {
  static var previews: some View {
    List {
      FrozenAccountNotificationRowView(model: .mock)
    }
  }
}
