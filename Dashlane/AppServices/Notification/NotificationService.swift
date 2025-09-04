import Combine
import CoreTypes
import Foundation
import LogFoundation
import SwiftTreats
import UIKit
import UserNotifications

class NotificationService: NSObject {
  private let notificationCenter = UNUserNotificationCenter.current()
  @Atomic
  private var notificationToken: Data?
  private let logger: Logger

  @Published
  private var deviceToken: Data?

  @Atomic
  private var remoteNotificationSubcriptions = Set<RemoteNotificationSubscription>()
  @Atomic
  private var userNotificationSubcriptions = Set<UserNotificationSubscription>()

  private var cancellables = Set<AnyCancellable>()

  init(
    logger: Logger,
    remoteDeviceTokenPublisher: PassthroughSubject<Data, Error> = UIApplication
      .remoteDeviceTokenPublisher,
    remoteNotificationPublisher: PassthroughSubject<RemoteNotification, Never> = UIApplication
      .remoteNotificationPublisher
  ) {
    self.logger = logger
    super.init()
    notificationCenter.delegate = self

    NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification).sink {
      [weak self] _ in
      self?.readDelivered​Notifications()
    }.store(in: &cancellables)

    configureRemoteNotification(
      remoteDeviceTokenPublisher: remoteDeviceTokenPublisher,
      remoteNotificationPublisher: remoteNotificationPublisher)
  }

  func registerForRemoteNotifications() {
    #if !targetEnvironment(simulator)
      UIApplication.shared.registerForRemoteNotifications()
    #endif
  }

  func remoteDeviceTokenPublisher() -> AnyPublisher<Data, Never> {
    return $deviceToken.compactMap { $0 }.eraseToAnyPublisher()
  }

  func remoteNotificationPublisher(for predicate: NotificationPredicate<RemoteNotification>)
    -> AnyPublisher<RemoteNotification, Never>
  {
    let subcription = RemoteNotificationSubscription(predicate: predicate)
    self.remoteNotificationSubcriptions.insert(subcription)
    let publisher = subcription.publisher.handleEvents(receiveCancel: {
      self.remoteNotificationSubcriptions.remove(subcription)
    })
    return publisher.receive(on: DispatchQueue.main).eraseToAnyPublisher()
  }

  func requestUserAuthorization() async {
    do {
      let status = await notificationCenter.notificationSettings().authorizationStatus
      guard status == .notDetermined else {
        logger.info("Notification auth status: \(status)")
        return
      }

      let granted = try await notificationCenter.requestAuthorization(options: [.alert, .sound])
      logger.info("Notification auth request result: \(granted)")
    } catch {
      logger.error("Notification auth request error", error: error)
    }
  }

  func userNotificationPublisher(for predicate: NotificationPredicate<UNNotification>)
    -> AnyPublisher<UserNotificationEvent, Never>
  {
    let subcription = UserNotificationSubscription(predicate: predicate)
    self.userNotificationSubcriptions.insert(subcription)
    let publisher = subcription.publisher.handleEvents(receiveCancel: {
      self.userNotificationSubcriptions.remove(subcription)
    })

    return publisher.receive(on: DispatchQueue.main).eraseToAnyPublisher()
  }

}

extension NotificationService {

  private func configureRemoteNotification(
    remoteDeviceTokenPublisher: PassthroughSubject<Data, Error>,
    remoteNotificationPublisher: PassthroughSubject<RemoteNotification, Never>
  ) {
    remoteDeviceTokenPublisher.catch { [weak self] error -> Empty<Data, Never> in
      self?.logger.error("Failed to register for remote notifications", error: error)
      return Empty()
    }.sink { [weak self] data in
      self?.logger.debug("Receive DeviceToken")
      self?.deviceToken = data
    }.store(in: &cancellables)

    remoteNotificationPublisher.sink { [weak self] notification in
      if let subscription = self?.remoteNotificationSubcriptions.first(for: notification) {
        self?.logger.debug("Receive notification \(notification)")
        subscription.publisher.send(notification)
      } else {
        self?.logger.debug("No subscription for notification \(notification)")
        notification.completionHandler(.noData)
      }
    }.store(in: &cancellables)

  }
}

extension NotificationService: UNUserNotificationCenterDelegate {
  func userNotificationCenter(
    _ center: UNUserNotificationCenter, willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    if let subcription = self.userNotificationSubcriptions.first(for: notification) {
      subcription.publisher.send(
        .willPresent(notification: notification, completionHandler: completionHandler))
    } else {
      completionHandler([])
    }
  }

  func userNotificationCenter(
    _ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    if let subcription = self.userNotificationSubcriptions.first(for: response.notification) {
      subcription.publisher.send(
        .didReceive(response: response, completionHandler: completionHandler))
    } else {
      completionHandler()
    }
  }
}

extension NotificationService {
  private func readDelivered​Notifications() {
    UNUserNotificationCenter.current().getDeliveredNotifications { [weak self] notifications in
      guard let self else {
        return
      }

      for notification in notifications {
        self.logger.debug(
          "readDelivered​Notifications userInfo: \(notification.request.content.userInfo)")

        guard let subscription = self.userNotificationSubcriptions.first(for: notification) else {
          return
        }

        let notificationCenter = self.notificationCenter
        subscription.publisher.send(
          .readDelivered(
            notification: notification,
            completionHandler: { [weak notificationCenter] strategy in
              if strategy == .delete {
                notificationCenter?.removeDeliveredNotifications(withIdentifiers: [
                  notification.request.identifier
                ])
              }
            }))
      }
    }
  }
}
