import Foundation
import UIKit
import Combine
import DashTypes
import UserNotifications

@MainActor
class NotificationService: NSObject {
    private let notificationCenter = UNUserNotificationCenter.current()
    private var notificationToken: Data?
    private let logger: Logger

    @Published
    private var deviceToken: Data?

    private var remoteNotificationSubcriptions = Set<RemoteNotificationSubscription>()
    private var userNotificationSubcriptions = Set<UserNotificationSubscription>()

    private var cancellables = Set<AnyCancellable>()

    init(logger: Logger,
         remoteDeviceTokenPublisher: PassthroughSubject<Data, Error> = UIApplication.remoteDeviceTokenPublisher,
         remoteNotificationPublisher: PassthroughSubject<RemoteNotification, Never> = UIApplication.remoteNotificationPublisher) {
        self.logger = logger
        super.init()
        notificationCenter.delegate = self

        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification).sink { [weak self] _ in
            self?.readDelivered​Notifications()
        }.store(in: &cancellables)

        configureRemoteNotification(remoteDeviceTokenPublisher: remoteDeviceTokenPublisher,
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

        func remoteNotificationPublisher(for predicate: NotificationPredicate<RemoteNotification>) -> AnyPublisher<RemoteNotification, Never> {
        let subcription = RemoteNotificationSubscription(predicate: predicate)
        self.remoteNotificationSubcriptions.insert(subcription)
        let publisher = subcription.publisher.handleEvents(receiveCancel: {
            self.remoteNotificationSubcriptions.remove(subcription)
        })
        return publisher.receive(on: DispatchQueue.main).eraseToAnyPublisher()
    }

        func requestUserAuthorization() {
        notificationCenter.requestAuthorization(options: [.alert, .sound]) {  [weak self] granted, error in

            if let error = error {
                self?.logger.error("Notification auth request error", error: error)
            } else {
                self?.logger.info("Notification auth request result: \(granted)")
            }
        }
    }

        func userNotificationPublisher(for predicate: NotificationPredicate<UNNotification>) -> AnyPublisher<UserNotificationEvent, Never> {
        let subcription = UserNotificationSubscription(predicate: predicate)
        self.userNotificationSubcriptions.insert(subcription)
        let publisher = subcription.publisher.handleEvents(receiveCancel: {
            self.userNotificationSubcriptions.remove(subcription)
        })

        return publisher.receive(on: DispatchQueue.main).eraseToAnyPublisher()
    }

}

extension NotificationService {

    private func configureRemoteNotification(remoteDeviceTokenPublisher: PassthroughSubject<Data, Error>,
                                             remoteNotificationPublisher: PassthroughSubject<RemoteNotification, Never>) {
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
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if let subcription = self.userNotificationSubcriptions.first(for: notification) {
            subcription.publisher.send(.willPresent(notification: notification, completionHandler: completionHandler))
        } else {
            completionHandler([])
        }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        if let subcription = self.userNotificationSubcriptions.first(for: response.notification) {
            subcription.publisher.send(.didReceive(response: response, completionHandler: completionHandler))
        } else {
            completionHandler()
        }
    }
}

extension NotificationService {
    private func readDelivered​Notifications() {
        UNUserNotificationCenter.current().getDeliveredNotifications { notifications in
            for notification in notifications {
                self.logger.debug("readDelivered​Notifications userInfo: \(notification.request.content.userInfo)")

                guard let subscription = self.userNotificationSubcriptions.first(for: notification) else {
                    return
                }

                subscription.publisher.send(.readDelivered(notification: notification, completionHandler: { [weak self] strategy in
                    if strategy == .delete {
                        self?.notificationCenter.removeDeliveredNotifications(withIdentifiers: [notification.request.identifier])
                    }
                }))
            }
        }
    }
}
