import CoreLocalization
import CorePremium
import CoreSettings
import CoreTypes
import Foundation
import UserNotifications

public class PremiumNotificationService {

  let login: String
  let premiumStatusProvider: PremiumStatusProvider
  let settings: UserSettings

  public init(
    login: String,
    premiumStatusProvider: PremiumStatusProvider,
    settings: UserSettings
  ) {
    self.login = login
    self.premiumStatusProvider = premiumStatusProvider
    self.settings = settings
    clearAllNotifications {
      self.addNotificationIfNeeded()
    }
  }

  func addNotificationIfNeeded() {
    let status = premiumStatusProvider.status
    guard status.b2bStatus?.statusCode != .inTeam,
      status.b2cStatus.familyStatus?.isAdmin != false,
      let endDate = status.b2cStatus.endDate,
      !status.b2cStatus.autoRenewal,
      status.b2cStatus.statusCode == .subscribed
    else {
      clearAllNotifications()
      return
    }
    let builder = PremiumNotificationBuilder()
    guard let notice = builder.notice(forEndDate: endDate) else {
      clearAllNotifications()
      return
    }

    let request = notice.makeNotificationRequest(forLogin: login)

    var sentNotification: Set<String> = settings[.premiumExpirationSentNotifications] ?? []
    guard !sentNotification.contains(notice.expirationNotice.notificationId) else {
      return
    }
    UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    sentNotification.insert(notice.expirationNotice.notificationId)
    settings[.premiumExpirationSentNotifications] = sentNotification
  }

  public func clearAllNotifications(completion: (() -> Void)? = nil) {
    UNUserNotificationCenter.current().getPendingNotificationRequests { pendingRequest in
      var requestIdentifiers = [String]()
      for request in pendingRequest {
        let userInfo = request.content.userInfo
        guard let code = userInfo[NotificationInfoKey.code.rawValue] as? Int else {
          continue
        }
        if code == NotificationCode.renewal.rawValue {
          requestIdentifiers.append(request.identifier)
        }
      }
      UNUserNotificationCenter.current().removePendingNotificationRequests(
        withIdentifiers: requestIdentifiers)
      completion?()
    }
  }
}
