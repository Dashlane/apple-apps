import UIKit
import Combine

enum UserNotificationEvent {
        case readDelivered(notification: UNNotification, completionHandler: (DeliveredNotificationStrategy) -> Void)
        case willPresent(notification: UNNotification, completionHandler: (UNNotificationPresentationOptions) -> Void)
        case didReceive(response: UNNotificationResponse, completionHandler: () -> Void)
}

enum DeliveredNotificationStrategy {
    case keep 
    case delete 
}

typealias UserNotificationSubscription = NotificationSubscription<UNNotification, UserNotificationEvent>

extension NotificationPredicate where Notification: UNNotification {
    static func local(_ identifier: LocalNotificationIdentifier) -> NotificationPredicate<UNNotification> {
        return .custom({ $0.request.identifier == identifier.rawValue })
    }
}
