import Foundation
import SecurityDashboard
import UIKit

extension IdentityDashboardService: IdentityDashboardSessionDelegate {

  public func present(_ breaches: [PopupAlertProtocol]) {
    assert(Thread.isMainThread)
    guard breaches.count != 0 else { return }
    breachesToPresent = breaches

    guard !breachesToPresent.isEmpty else {
      return
    }

    if UIApplication.shared.applicationState == .background {
      sendLocalNotification()
    }
  }

  public func credentialsDataDidUpdate() {
    logger.debug("credential data did update")
  }

  public func passwordHealthDataDidUpdate() {
    logger.debug("Password Health data did update")
    notificationManager.post(notification: .securityDashboardDidRefresh)
    session.report(spaceId: nil) { [weak self] report in
      self?.logger.debug("\(report)")
      self?.widgetService.refresh(withReport: report)
    }
  }

  func sendLocalNotification() {
    let content = UNMutableNotificationContent()
    content.title = L10n.Localizable.securityAlertNotificationTitle
    content.body = L10n.Localizable.securityAlertNotificationBody
    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
    let request = UNNotificationRequest(
      identifier: LocalNotificationIdentifier.securityAlert.rawValue,
      content: content, trigger: trigger)
    let center = UNUserNotificationCenter.current()
    center.add(request) { [weak self] error in
      if let error = error {
        self?.logger.error("failed to add local notification", error: error)
      }
    }
  }
}
