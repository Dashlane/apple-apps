import CoreTypes
import Foundation
import UserNotifications

final class OTPLocalNotification: LocalNotification {
  var pin: String
  var itemId: String
  var hasClipboardOverride: Bool
  var domain: String?

  var delay: Double = 30.0
  var identifier: String { return "otpLocalNotificationIdentifier" }

  init(pin: String, itemId: String, hasClipboardOverride: Bool, domain: String?) {
    self.pin = pin
    self.itemId = itemId
    self.hasClipboardOverride = hasClipboardOverride
    self.domain = domain
  }

  func build() -> UNMutableNotificationContent {
    let notificationContent = UNMutableNotificationContent()
    let categoryIdentifier = self.identifier

    var formattedPin = pin
    formattedPin.insert(
      " ", at: formattedPin.index(formattedPin.startIndex, offsetBy: formattedPin.count / 2))

    notificationContent.title = L10n.Localizable.otpNotificationTitle(formattedPin)
    notificationContent.body =
      hasClipboardOverride
      ? L10n.Localizable.otpNotificationBodyClipboard : L10n.Localizable.otpNotificationBody
    notificationContent.categoryIdentifier = categoryIdentifier
    notificationContent.userInfo = [
      NotificationInfoKey.deepLinkingURL.rawValue: "dashlane:///items/\(itemId)"
    ]

    return notificationContent
  }

  func shouldSendNotification(
    previousNotification: LocalNotification?, previousNotificationDate: Date?
  ) -> Bool {
    guard let pNotification = previousNotification, let pNotificationDate = previousNotificationDate
    else { return true }

    if let pOtpNotification = pNotification as? OTPLocalNotification,
      pOtpNotification.pin != self.pin
    {
      return true
    }

    return Date().timeIntervalSince(pNotificationDate) > self.delay
  }
}
