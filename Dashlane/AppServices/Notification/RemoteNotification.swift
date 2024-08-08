import Combine
import Foundation
import UIKit

struct RemoteNotification {
  let userInfo: [AnyHashable: Any]
  let completionHandler: (UIBackgroundFetchResult) -> Void
}

typealias RemoteNotificationSubscription = NotificationSubscription<
  RemoteNotification, RemoteNotification
>
