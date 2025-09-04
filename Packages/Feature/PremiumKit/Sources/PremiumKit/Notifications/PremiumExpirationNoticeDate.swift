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
        title: CoreL10n.noBackupSyncPremiumRenewalTitle,
        message: CoreL10n.noBackupSyncPremiumRenewalMsg)
    case .lessThanADayToExpire:
      return PremiumNotificationInfo(
        title: CoreL10n.renewalNoticeReminderDminus1Title,
        message: CoreL10n.renewalNoticeReminderDminus1Msg)
    case .lessThanFiveDaysToExpire(let days):
      return PremiumNotificationInfo(
        title: CoreL10n.renewalNoticeReminderDminus5Title,
        message: CoreL10n.renewalNoticeReminderDminus5Msg(days))
    case .lessThanTwentyFiveDaysToExpire(let daysLeft):
      return PremiumNotificationInfo(
        title: CoreL10n.renewalNoticeReminderDminus25Title,
        message: CoreL10n.renewalNoticeReminderDminus25Msg(daysLeft))
    }
  }
}
