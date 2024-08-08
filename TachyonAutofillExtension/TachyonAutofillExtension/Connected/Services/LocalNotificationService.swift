import UIKit
import UserNotifications

final class LocalNotificationService {
  private var lastNotification: (localNotification: LocalNotification, date: Date)?

  func send(_ localNotification: LocalNotification) {

    guard
      localNotification.shouldSendNotification(
        previousNotification: lastNotification?.localNotification,
        previousNotificationDate: lastNotification?.date)
    else { return }

    let localNotificationContent = localNotification.build()

    let request = UNNotificationRequest(
      identifier: localNotification.identifier, content: localNotificationContent, trigger: nil)

    UNUserNotificationCenter.current().add(request) { [weak self] (error) in
      guard error == nil else { return }

      self?.lastNotification = (localNotification, Date())
    }
  }
}
