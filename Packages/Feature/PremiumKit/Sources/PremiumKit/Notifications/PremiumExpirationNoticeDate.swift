import CoreLocalization
import Foundation

struct PremiumNotificationInfo {
  let title: String
  let message: String
}

enum PremiumExpirationNoticeDate: Equatable {
  case expired
  case lessThanADayToExpire
  case lessThanFiveDaysToExpire(daysLeft: Int)
  case lessThanTwentyFiveDaysToExpire(daysLeft: Int)

  var notificationId: String {
    switch self {
    case .expired:
      return "expired"
    case .lessThanADayToExpire:
      return "lessThanADay"
    case .lessThanFiveDaysToExpire(let days):
      return "lessThan5Days\(days)"
    case .lessThanTwentyFiveDaysToExpire(let days):
      return "lessThan25Days\(days)"
    }
  }

  var renewalNotificationInfo: PremiumNotificationInfo {
    switch self {
    case .expired:
      return PremiumNotificationInfo(
        title: L10n.Core.noBackupSyncPremiumRenewalTitle,
        message: L10n.Core.noBackupSyncPremiumRenewalMsg)
    case .lessThanADayToExpire:
      return PremiumNotificationInfo(
        title: L10n.Core.renewalNoticeReminderDminus1Title,
        message: L10n.Core.renewalNoticeReminderDminus1Msg)
    case .lessThanFiveDaysToExpire(let days):
      return PremiumNotificationInfo(
        title: L10n.Core.renewalNoticeReminderDminus5Title,
        message: L10n.Core.renewalNoticeReminderDminus5Msg(days))
    case .lessThanTwentyFiveDaysToExpire(let daysLeft):
      return PremiumNotificationInfo(
        title: L10n.Core.renewalNoticeReminderDminus25Title,
        message: L10n.Core.renewalNoticeReminderDminus25Msg(daysLeft))
    }
  }
}
