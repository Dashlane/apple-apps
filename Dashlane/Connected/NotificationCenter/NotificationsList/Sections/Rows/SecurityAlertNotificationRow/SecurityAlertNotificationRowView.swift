import SwiftUI
import UIDelight

struct SecurityAlertNotificationRowView: View {
    let model: SecurityAlertNotificationRowViewModel

    @State
    private var showAlertViewController = false

    var body: some View {
        BaseNotificationRowView(icon: model.notification.icon,
                                iconBackgroundColor: Color.red,
                                title: model.notification.title,
                                description: model.notification.description) {
            self.model.openUnresolvedAlert()
        }
    }
}

struct SecurityAlertNotificationRowView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            SecurityAlertNotificationRowView(model: .mock)
        }
    }
}
