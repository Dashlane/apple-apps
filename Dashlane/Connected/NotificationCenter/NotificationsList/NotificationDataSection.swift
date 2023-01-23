import Foundation

struct NotificationDataSection: Identifiable {
    let category: NotificationCategory
    let notifications: [DashlaneNotification]

    var id: String {
        category.id
    }
}
