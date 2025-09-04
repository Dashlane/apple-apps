import Combine
import CoreNetworking
import CoreSession
import CoreSettings
import CoreTypes
import DashlaneAPI
import Foundation
import LogFoundation
import NotificationKit
import UIKit
import VaultKit

class SessionNotificationService {
  let settings: UserSettings
  let login: Login
  let logger: Logger
  let notificationService: NotificationService
  let userDeviceAPIClient: UserDeviceAPIClient

  var subscriptions = Set<AnyCancellable>()

  @MainActor
  init(
    login: Login,
    notificationService: NotificationService,
    syncService: SyncServiceProtocol,
    brazeService: BrazeServiceProtocol,
    settings: UserSettings,
    userDeviceAPIClient: UserDeviceAPIClient,
    logger: Logger
  ) {
    self.login = login
    self.notificationService = notificationService
    self.settings = settings
    self.userDeviceAPIClient = userDeviceAPIClient
    self.logger = logger

    self.remoteNotificationPublisher(for: .name(.syncRequest)).sink { notification in
      guard UIApplication.shared.applicationState == .active else {
        notification.completionHandler(.noData)
        return
      }
      syncService.sync(triggeredBy: .push)
      notification.completionHandler(.noData)
    }.store(in: &subscriptions)

    notificationService.remoteDeviceTokenPublisher()
      .receive(on: DispatchQueue.main)
      .sink { [weak self] token in
        guard let self = self else {
          return
        }
        let tokenInSetting: Data? = settings[.deviceTokenForRemoteNotifications]
        if token != tokenInSetting {
          Task {
            await self.sendToken(token)
          }
          brazeService.registerForNotifications(deviceToken: token)
        }

      }.store(in: &subscriptions)
  }

  func unload() {
    Task {
      await clearPushNotification()
    }
  }
}

extension SessionNotificationService {
  private func sendToken(_ token: Data) async {
    let tokenString = token.map { String(format: "%02x", $0) }.joined()
    do {
      try await userDeviceAPIClient.devices.setPushNotificationID(
        pushID: tokenString,
        type: .ios,
        sendToAppboy: true)

      settings[.deviceTokenForRemoteNotifications] = token
      logger.info("Registered notification token: \(tokenString)")
    } catch {
      logger.error("Failed to register notification token", error: error)
    }
  }

  func clearPushNotification() async {
    var tokenInSetting: Data? = settings[.deviceTokenForRemoteNotifications]
    guard let token = tokenInSetting else {
      return
    }
    do {
      try await userDeviceAPIClient.devices.clearPushNotificationID(
        pushID: token.map { String(format: "%02x", $0) }.joined())
      tokenInSetting = nil
      settings[.deviceTokenForRemoteNotifications] = tokenInSetting
      logger.info("Cleared push notification ID")
    } catch {
      logger.error("Couldn't clear push notification ID", error: error)
    }
  }
}

extension SessionNotificationService {
  func remoteNotificationPublisher(for predicate: NotificationPredicate<RemoteNotification>)
    -> AnyPublisher<RemoteNotification, Never>
  {
    return notificationService.remoteNotificationPublisher(for: predicate).compactMap {
      [weak self] notification in
      guard let self = self,
        notification.hasLogin(self.login)
      else {
        notification.completionHandler(.failed)
        return nil
      }
      return notification
    }.eraseToAnyPublisher()
  }

  func userNotificationPublisher(for predicate: NotificationPredicate<UNNotification>)
    -> AnyPublisher<UserNotificationEvent, Never>
  {
    return notificationService.userNotificationPublisher(for: predicate).compactMap {
      [weak self] event in
      guard let self = self else {
        return nil
      }
      switch event {
      case let .readDelivered(notification, completionHandler):
        guard notification.hasLogin(self.login) else {
          completionHandler(DeliveredNotificationStrategy.keep)
          return nil
        }
        return event

      case let .willPresent(notification, completionHandler):
        guard notification.hasLogin(self.login) else {
          completionHandler([])
          return nil
        }
        return event

      case let .didReceive(response, completionHandler):
        guard response.notification.hasLogin(self.login) else {
          completionHandler()
          return nil
        }
        return event
      }

    }.eraseToAnyPublisher()
  }

}

extension SessionNotificationService {
  @MainActor
  static var fakeService: SessionNotificationService {
    .init(
      login: .init("_"),
      notificationService: .init(logger: .mock),
      syncService: .mock(),
      brazeService: BrazeService.mock,
      settings: .mock,
      userDeviceAPIClient: .mock({}),
      logger: .mock)
  }
}
