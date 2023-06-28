import SwiftUI

struct SharingRequestNotificationRowView: View {
    let model: SharingRequestNotificationRowViewModel

    var body: some View {
        BaseNotificationRowView(icon: model.notification.icon,
                                title: model.notification.title,
                                description: model.notification.description) {
            model.openSharingCenter()
        }
    }
}

struct SharingRequestNotificationRowView_Previews: PreviewProvider {
    static var previews: some View {
        List {
            SharingRequestNotificationRowView(model: SharingRequestNotificationRowViewModel.mock)
        }
    }
}
