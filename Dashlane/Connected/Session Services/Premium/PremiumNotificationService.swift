import Foundation
import CorePremium
import UserNotifications

class PremiumNotificationService {

    let login: String
    weak var premiumService: PremiumService?

    init(login: String, premiumService: PremiumService) {
        self.login = login
        self.premiumService = premiumService
        clearAllNotifications {
            self.setup()
        }
    }

    func setup() {
        guard let endDate = premiumService?.status?.endDate else {
            clearAllNotifications()
            return
        }

        let lessThanADayToExpire = Calendar.current.date(byAdding: .day, value: -1, to: endDate)
        let lessThanFiveDaysToExpire = Calendar.current.date(byAdding: .day, value: -5, to: endDate)
        let lessThanTwentyFiveDaysToExpire = Calendar.current.date(byAdding: .day, value: -25, to: endDate)
        let expiryDate = endDate

        [expiryDate,
         lessThanADayToExpire,
         lessThanFiveDaysToExpire,
         lessThanTwentyFiveDaysToExpire].compactMap {$0}.forEach { noticeDate in
            guard noticeDate.timeIntervalSinceNow >= 0.0 else {
                return
            }
            let calendar = NSCalendar.current
            let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: noticeDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let identifier = NotificationInfoKey.code.rawValue + "-" + "\(noticeDate)"

            guard let expirationStatus = expirationNoticeDate(from: noticeDate, endDate: endDate) else {
                return
            }
            let content = UNMutableNotificationContent()
            let renewalNotificationInfo = expirationStatus.renewalNotificationInfo
            content.body = renewalNotificationInfo.message
            content.title = renewalNotificationInfo.title
            content.userInfo = [NotificationInfoKey.login.rawValue: login,
                                NotificationInfoKey.code.rawValue: NotificationCode.renewal.rawValue,
                                NotificationInfoKey.deepLinkingURL.rawValue: "dashlane:///getpremium"]

            let request = UNNotificationRequest(identifier: identifier,
                                                content: content,
                                                trigger: trigger)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }
    }

    func expirationNoticeDate(from noticeDate: Date, endDate: Date) -> PremiumExpirationNoticeDate? {

        let calendar = NSCalendar.current
        let today = calendar.startOfDay(for: noticeDate)
        let premiumExpiry = calendar.startOfDay(for: endDate)
        let dateComponents = calendar.dateComponents([.day, .hour, .minute], from: today, to: premiumExpiry)

        let daysToExpiration = dateComponents.day ?? 0
        let hoursToExpiration = dateComponents.hour ?? 0
        let minutesToExpiration = dateComponents.minute ?? 0

        if daysToExpiration <= 0 && hoursToExpiration <= 0 && minutesToExpiration <= 0 {
            return .expired
        } else if hoursToExpiration >= 0 && hoursToExpiration <= 24 && daysToExpiration < 2 {
            return .lessThanADayToExpire(hoursLeft: hoursToExpiration)
        } else if daysToExpiration <= 5 {
            return .lessThanFiveDaysToExpire(daysLeft: daysToExpiration)
        } else if daysToExpiration <= 25 {
            return .lessThanTwentyFiveDaysToExpire(daysLeft: daysToExpiration)
        }
        return nil
    }

    func clearAllNotifications(completion: (() -> Void)? = nil) {
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
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: requestIdentifiers)
            completion?()
        }
    }
}

enum PremiumExpirationNoticeDate {
    case expired
    case lessThanADayToExpire(hoursLeft: Int)
    case lessThanFiveDaysToExpire(daysLeft: Int)
    case lessThanTwentyFiveDaysToExpire(daysLeft: Int)

    var renewalNotificationInfo: PremiumNotificationInfo {
        switch self {
        case .expired:
            return PremiumNotificationInfo(title: L10n.Localizable.noBackupSyncPremiumRenewalTitle,
                                           message: L10n.Localizable.noBackupSyncPremiumRenewalMsg)
        case .lessThanADayToExpire:
            return PremiumNotificationInfo(title: L10n.Localizable.renewalNoticeReminderDminus1Title,
                                           message: L10n.Localizable.renewalNoticeReminderDminus1Msg)
        case .lessThanFiveDaysToExpire(let days):
            return PremiumNotificationInfo(title: L10n.Localizable.renewalNoticeReminderDminus5Title,
                                           message: L10n.Localizable.renewalNoticeReminderDminus5Msg(days))
        case .lessThanTwentyFiveDaysToExpire(let daysLeft):
            return PremiumNotificationInfo(title: L10n.Localizable.renewalNoticeReminderDminus25Title,
                                           message: L10n.Localizable.renewalNoticeReminderDminus25Msg(daysLeft))
        }
    }
}

struct PremiumNotificationInfo {
    let title: String
    let message: String
}
