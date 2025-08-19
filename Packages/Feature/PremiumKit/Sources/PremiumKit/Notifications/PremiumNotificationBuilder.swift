import CoreTypes
import Foundation
import UserNotifications

struct PremiumNotificationBuilder {

  let currentDate: Date

  init(currentDate: Date = Date()) {
    self.currentDate = currentDate
  }

  func notice(forEndDate endDate: Date) -> Notice? {
    let lessThanADayToExpire = Calendar.current.date(byAdding: .day, value: -1, to: endDate)
    let lessThanFiveDaysToExpire = Calendar.current.date(byAdding: .day, value: -5, to: endDate)
    let lessThanTwentyFiveDaysToExpire = Calendar.current.date(
      byAdding: .day, value: -25, to: endDate)
    let expiryDate = endDate
    let expirations = [
      expiryDate,
      lessThanADayToExpire,
      lessThanFiveDaysToExpire,
      lessThanTwentyFiveDaysToExpire,
    ]
    let notices: [Notice] =
      expirations
      .compactMap({ $0 })
      .compactMap({ noticeDate -> Notice? in
        guard noticeDate.timeIntervalSince(currentDate) < 0.0 else {
          return nil
        }
        guard let expirationStatus = expirationNoticeDate(from: noticeDate, endDate: endDate) else {
          return nil
        }
        let dateToTrigger = noticeDate <= Date() ? Date().addingTimeInterval(30) : noticeDate
        return Notice(
          expirationNotice: expirationStatus,
          noticeDate: dateToTrigger)
      })
    return notices.first
  }

  func expirationNoticeDate(from noticeDate: Date, endDate: Date) -> PremiumExpirationNoticeDate? {

    let dateComponents = Calendar.current.dateComponents(
      [.day, .hour, .minute], from: currentDate, to: endDate)

    let daysToExpiration = dateComponents.day ?? 0
    let hoursToExpiration = dateComponents.hour ?? 0
    let minutesToExpiration = dateComponents.minute ?? 0

    if daysToExpiration <= 0 && hoursToExpiration <= 0 && minutesToExpiration <= 0 {
      return .expired
    } else if hoursToExpiration >= 0 && hoursToExpiration <= 24 && daysToExpiration < 2 {
      return .lessThanADayToExpire
    } else if daysToExpiration <= 5 {
      return .lessThanFiveDaysToExpire(daysLeft: daysToExpiration)
    } else if daysToExpiration <= 25 {
      return .lessThanTwentyFiveDaysToExpire(daysLeft: daysToExpiration)
    }
    return nil
  }
}

struct Notice: Equatable {
  let identifier: String
  let expirationNotice: PremiumExpirationNoticeDate
  let noticeDate: Date

  init(
    expirationNotice: PremiumExpirationNoticeDate,
    noticeDate: Date
  ) {
    let currentYear = Calendar.current.component(.year, from: .now)
    self.identifier = "\(NotificationInfoKey.code.rawValue)-PremiumNotification-\(currentYear)"
    self.expirationNotice = expirationNotice
    self.noticeDate = noticeDate
  }

  func makeNotificationRequest(forLogin login: String) -> UNNotificationRequest {
    let content = UNMutableNotificationContent()
    let renewalNotificationInfo = expirationNotice.renewalNotificationInfo
    content.body = renewalNotificationInfo.message
    content.title = renewalNotificationInfo.title
    content.userInfo = [
      NotificationInfoKey.login.rawValue: login,
      NotificationInfoKey.code.rawValue: NotificationCode.renewal.rawValue,
      NotificationInfoKey.deepLinkingURL.rawValue: "dashlane:///getpremium",
    ]
    let dateComponents = Calendar.current.dateComponents(
      [.year, .month, .day, .hour, .minute, .second], from: noticeDate)
    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

    return UNNotificationRequest(
      identifier: identifier,
      content: content,
      trigger: trigger)
  }
}
