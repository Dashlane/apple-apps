import Foundation
import UserNotifications

struct LocalNotificationContent {
  var title: String
  var body: String
}

protocol LocalNotification: AnyObject {
  var delay: Double { get }
  var identifier: String { get }

  func build() -> UNMutableNotificationContent
  func shouldSendNotification(
    previousNotification: LocalNotification?, previousNotificationDate: Date?
  ) -> Bool
}
