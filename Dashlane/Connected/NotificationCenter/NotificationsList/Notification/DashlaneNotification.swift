import Foundation
import SwiftUI

public protocol DashlaneNotification {
  var id: String { get }
  var state: NotificationCenterService.Notification.State { get }
  var creationDate: Date { get }
  var icon: SwiftUI.Image { get }
  var title: String { get }
  var description: String { get }
  var category: NotificationCategory { get }
  var notificationActionHandler: NotificationActionHandler { get }
  var kind: NotificationCenterService.Notification { get }
  var dismissAction: () -> Void { get }
}

extension DashlaneNotification {
  var dismissAction: () -> Void { {} }
}
