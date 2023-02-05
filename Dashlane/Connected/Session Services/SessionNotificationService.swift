import Foundation
import Combine
import CoreNetworking
import DashTypes
import CoreSession
import DashlaneReportKit
import DashlaneAppKit
import CoreSettings
import UIKit
import NotificationKit

class SessionNotificationService {
    let settings: UserSettings
    let login: Login
    let logger: Logger
    let usageLogService: UsageLogServiceProtocol
    let notificationService: NotificationService
    let webService: LegacyWebService

    var subcriptions = Set<AnyCancellable>()

    @MainActor
    init(login: Login,
         notificationService: NotificationService,
         usageLogService: UsageLogServiceProtocol,
         syncService: SyncServiceProtocol,
         brazeService: BrazeServiceProtocol,
         settings: UserSettings,
         webService: LegacyWebService,
         logger: Logger) {
        self.login = login
        self.notificationService = notificationService
        self.usageLogService = usageLogService
        self.settings = settings
        self.webService = webService
        self.logger = logger

        Task {
            await self.remoteNotificationPublisher(for: .name(.syncRequest)).sink { notification in
                guard UIApplication.shared.applicationState == .active else {
                    notification.completionHandler(.noData)
                    return
                }
                syncService.sync(triggeredBy: .push)
                notification.completionHandler(.noData) 
            }.store(in: &subcriptions)
        }

        notificationService.remoteDeviceTokenPublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] token in
                guard let self = self else {
                    return
                }
                let tokenInSetting: Data? = settings[.deviceTokenForRemoteNotifications]
                if token != tokenInSetting {
                    self.sendToken(token)
                    brazeService.registerForNotifications(deviceToken: token)
                }
            }.store(in: &subcriptions)
    }
}

extension SessionNotificationService {
    private struct StringParser: ResponseParserProtocol {
        func parse(data: Data) throws -> String? {
            return String(data: data, encoding: .utf8)
        }
    }

    private func sendToken(_ token: Data) {

        let tokenString = token.map { String(format: "%02x", $0) }.joined()
        let logger = self.logger
        let settings = self.settings

        webService.sendRequest(to: "/1/devices/setPushNotificationID",
                               using: .post,
                               params: ["type": "ios",
                                        "pushID": tokenString,
                                        "sendToAppboy": 1],
                               contentFormat: .queryString,
                               needsAuthentication: true,
                               responseParser: StringParser()) { result in
            guard let string = try? result.get(), string.range(of: "OK") != nil else {
                logger.warning("Failed to register notification token")
                return
            }
            settings[.deviceTokenForRemoteNotifications] = token
            logger.info("Registered notification token: \(tokenString)")
        }
    }
}

extension SessionNotificationService {
        func remoteNotificationPublisher(for predicate: NotificationPredicate<RemoteNotification>) async -> AnyPublisher<RemoteNotification, Never> {
        return await notificationService.remoteNotificationPublisher(for: predicate).compactMap { [weak self] notification in
            guard  let self = self,
                   notification.hasLogin(self.login) else {
                notification.completionHandler(.failed)
                return nil
            }
            return notification
        }.eraseToAnyPublisher()
    }

        func userNotificationPublisher(for predicate: NotificationPredicate<UNNotification>) async -> AnyPublisher<UserNotificationEvent, Never> {
        return await notificationService.userNotificationPublisher(for: predicate).compactMap { [weak self] event in
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
                if let template = response.notification.userInfo["template"] as? String,
                   let notificationType = UsageLogCode50Notifications.TypeType(rawValue: template) {
                    self.usageLogService.post(UsageLogCode50Notifications(action: .click,
                                                                          type: notificationType))
                }
                return event
            }

        }.eraseToAnyPublisher()
    }

}

extension SessionNotificationService {
    @MainActor
    static var fakeService: SessionNotificationService {
        .init(login: .init("_"),
              notificationService: .init(logger: LoggerMock()),
              usageLogService: UsageLogService.fakeService,
              syncService: SyncServiceMock(),
              brazeService: BrazeService.mock,
              settings: .mock,
              webService: LegacyWebServiceMock(response: ""),
              logger: LoggerMock())
    }
}
