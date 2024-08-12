import Foundation

struct NotificationDataSection: Identifiable, Hashable {
  let category: NotificationCategory
  let notifications: [DashlaneNotification]

  var id: String {
    category.id
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(category)
  }

  static func == (lhs: NotificationDataSection, rhs: NotificationDataSection) -> Bool {
    lhs.category == rhs.category
  }
}
