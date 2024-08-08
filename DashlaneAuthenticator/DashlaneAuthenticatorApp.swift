import CoreUserTracking
import SwiftUI
import UIKit

@main
struct Dashlane_AuthenticatorApp: App {
  @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate

  let appServices = AppServices()

  init() {
    UITableView.appearance().backgroundColor = nil
  }

  var body: some Scene {
    WindowGroup {
      RootView(model: RootviewModel(appservices: appServices))
        .environment(\.report, ReportAction(reporter: appServices.activityReporter))
    }
  }
}

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
  ) -> Bool {
    return true
  }

  func application(
    _ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    UIApplication.remoteDeviceTokenPublisher.send(deviceToken)
    print("didRegisterForRemoteNotificationsWithDeviceToken: \(deviceToken)")
  }
  func application(
    _ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error
  ) {
    UIApplication.remoteDeviceTokenPublisher.send(completion: .failure(error))
    print("didFailToRegisterForRemoteNotificationsWithError: \(error)")
  }

  func application(
    _ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
    fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
  ) {
    guard let id = userInfo["notificationId"] as? String else {
      completionHandler(.noData)
      return
    }
    let center = UNUserNotificationCenter.current()
    center.removeDeliveredNotifications(withIdentifiers: [id])
    completionHandler(.noData)
  }
}
