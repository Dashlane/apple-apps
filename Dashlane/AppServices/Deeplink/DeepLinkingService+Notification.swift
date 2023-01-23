import Foundation
import Combine
import NotificationKit
import UIKit

extension DeepLinkingService {

    func configureDeeplinksFromNotifications() {
        Task {
            await configurePremium()
            await configureTokenAndDevice()
            await configureSharing()
            await configureLocalNotification()
            await configureBraze()
            await configureDarkWebMonitoring()
        }
    }

    private func configurePremium() async {
        await notificationService.userNotificationPublisher(for: .code(.trialUser)).onlyResponse().sink {  [weak self] (response, completion) in
            if let deepLink = response.notification.deepLink {
                self?.handleLink(deepLink)
            }

            completion()
        }.store(in: &subscriptions)

        await notificationService.userNotificationPublisher(for: .code(.renewal)).onlyResponse().sink {  [weak self] (response, completion) in
            if let deepLink = response.notification.deepLink {
                self?.handleLink(deepLink)
            }

            completion()
        }.store(in: &subscriptions)
    }

    private func configureTokenAndDevice() async {
        await notificationService.userNotificationPublisher(for: .code(.token)).sink { [weak self] event in
            let isContentVisible = self?.sessionLifeCycleHandler?.sessionState.isContentVisible == true
            switch event {
            case let .readDelivered(_, completionHandler):
                                completionHandler(.delete)

                        case let .willPresent(notification, completionHandler) where isContentVisible:

                self?.handleLink(.token(notification.securityToken))
                completionHandler([])
            case let .willPresent(_, completionHandler):
                completionHandler([.list, .banner])
            case let .didReceive(response, completionHandler):
                                self?.handleLink(.token(response.notification.securityToken))
                completionHandler()
            }
        }.store(in: &subscriptions)

        await notificationService.userNotificationPublisher(for: .code(.general)).onlyResponse().sink { [weak self] (response, completion) in
            let postNotificationValue = response.notification[infoKey: NotificationInfoKey.postNotificationValue, type: String.self]
            guard postNotificationValue == "newDeviceConnected" else {
                completion()
                return
            }
            self?.handleLink(.other(.devices))
            completion()
        }.store(in: &subscriptions)
    }

    private func configureSharing() async {
        await notificationService.userNotificationPublisher(for: .code(.sharingEventItemGroup)).sink { [weak self] event in
            switch event {
            case let .readDelivered(_, completionHandler):
                                completionHandler(.delete)

            case let .willPresent(_, completionHandler):
                completionHandler(self?.sessionLifeCycleHandler?.sessionState.isContentVisible == true ? [] : [.list, .banner])

            case let .didReceive(_, completionHandler):
                                self?.handleLink(.other(.sharing))
                completionHandler()
            }
        }.store(in: &subscriptions)
    }

    private func configureLocalNotification() async {
        await notificationService.userNotificationPublisher(for: .local(.tachyonOTPDisplay)).onlyResponse().sink { [weak self] (response, completion) in
            if let deepLink = response.notification.deepLink {
                self?.handleLink(deepLink)
            }
                        completion()
        }.store(in: &subscriptions)

        await notificationService.userNotificationPublisher(for: .local(.autofillReminder)).onlyResponse().sink { [weak self] (response, completion) in
            if let deepLink = response.notification.deepLink {
                self?.handleLink(deepLink)
            }
            completion()
        }.store(in: &subscriptions)
    }

    private func configureBraze() async {
        await notificationService.userNotificationPublisher(for: .custom({ $0.userInfo["ab"] != nil }))
        .onlyResponse()
            .sink { [weak self] (response, completion) in
                if let deepLink = response.notification.deepLink {
                    self?.handleLink(deepLink)
                }
                self?.brazeService.didReceive(notification: response, completion: completion)
        }.store(in: &subscriptions)
    }

    private func configureDarkWebMonitoring() async {
        await notificationService.userNotificationPublisher(for: .code(.darkWebAlert)).sink { [weak self] event in
            switch event {
            case let .readDelivered(_, completionHandler):
                completionHandler(.keep)
            case let .willPresent(_, completionHandler):
                completionHandler([.list, .banner])
            case let .didReceive(_, completionHandler):
                self?.handleLink(.tool(.darkWebMonitoring))
                completionHandler()
            }
        }.store(in: &subscriptions)
    }
}

extension NotificationInfoContainer {
    var deepLink: DeepLink? {
        guard let deeplinkString = self[infoKey: NotificationInfoKey.deepLinkingURL, type: String.self],
            let url = URL(string: deeplinkString),
            let deepLink = DeepLink(url: url) else {
                return nil
        }
        return deepLink
    }
}

extension DeepLinkingService {
    func handle(_ notification: NotificationInfoContainer) {
        guard let deepLink = notification.deepLink else {
            return
        }
        handleLink(deepLink)
    }
}

extension Publisher where Output == UserNotificationEvent {
    func onlyResponse() -> AnyPublisher<(UNNotificationResponse, () -> Void), Failure> {
        return compactMap { event -> ((UNNotificationResponse, () -> Void))? in
            switch event {
                case let .readDelivered(_, completionHandler):
                    completionHandler(.keep)
                    return nil

                case let .willPresent(_, completionHandler):
                    completionHandler([.list, .banner])
                    return nil

                case let .didReceive(response, completionHandler):
                    return (response, completionHandler)
            }
        }.eraseToAnyPublisher()
    }
}

private extension UNNotification {
        var securityToken: String? {
        return (userInfo["data"] as? [String: String])?["token"]
    }
}
