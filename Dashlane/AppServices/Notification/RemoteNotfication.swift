import Foundation
import UIKit
import Combine

struct RemoteNotification {
    let userInfo: [AnyHashable: Any]
    let completionHandler: (UIBackgroundFetchResult) -> Void
}

typealias RemoteNotificationSubscription = NotificationSubscription<RemoteNotification, RemoteNotification>
