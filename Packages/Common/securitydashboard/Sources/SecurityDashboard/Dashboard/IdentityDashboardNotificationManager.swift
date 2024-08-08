import Foundation

public struct IdentityDashboardNotificationManager {

  private let notificationCenter = NotificationCenter()

  public init() {}

  public enum NotificationType: String {
    case breachesDataSourceDidUpdate
    case credentialsDataSourceDidUpdate
    case dataLeakMonitoringEmailsDidUpdate
    case securityDashboardDidRefresh

    var name: Notification.Name {
      return Notification.Name(self.rawValue)
    }
  }

  public func addObserver(
    observer: Any, selector: Selector, notification: NotificationType, object: Any? = nil
  ) {
    notificationCenter.addObserver(
      observer, selector: selector, name: notification.name, object: object)
  }

  public func removeObserver(
    observer: Any, notification: NotificationType? = nil, object: Any? = nil
  ) {
    notificationCenter.removeObserver(observer, name: notification?.name, object: object)
  }

  public func post(notification: NotificationType, object: Any? = nil) {
    notificationCenter.post(name: notification.name, object: object)
  }

  public func publisher(for notification: NotificationType) -> NotificationCenter.Publisher {
    return notificationCenter.publisher(for: notification.name)
  }
}
