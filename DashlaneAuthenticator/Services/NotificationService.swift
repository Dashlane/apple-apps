import Foundation
import Combine
import UIKit
import CoreSession
import DashTypes
import CoreUserTracking
import DashlaneAppKit

extension UIApplication {
        static let remoteDeviceTokenPublisher = PassthroughSubject<Data, Error>()
}

enum NotificationAction: String {
    case approve = "APPROVE_ACTION"
    case deny = "DENY_ACTION"
}

enum NotificationActionCategory: String {
    case authentication = "WELCOME_AUTHENTICATOR"
    case authenticationRequest = "AUTHENTICATION_REQUEST"
}

public enum Notification: Identifiable {
    public var id: String {
        switch self {
        case .welcome:
            return NotificationActionCategory.authentication.rawValue
        case .requestAuthentication:
            return NotificationActionCategory.authenticationRequest.rawValue
        }
    }
    case welcome
    case requestAuthentication(AuthenticationRequest)
}

class NotificationService: NSObject, Mockable {
    private let notificationCenter = UNUserNotificationCenter.current()

    @Published
    private var deviceToken: Data?

    private var cancellables = Set<AnyCancellable>()

    public let remoteNotificationPublisher = CurrentValueSubject<Notification?, Never>(nil)
    let apiClient: AuthenticatorAPIClient
    let sessionsContainer: SessionsContainerProtocol
    let activityReporter: ActivityReporterProtocol

    init(apiClient: AuthenticatorAPIClient,
         sessionsContainer: SessionsContainerProtocol,
         activityReporter: ActivityReporterProtocol,
         remoteDeviceTokenPublisher: PassthroughSubject<Data, Error> = UIApplication.remoteDeviceTokenPublisher) {
        self.apiClient = apiClient
        self.sessionsContainer = sessionsContainer
        self.activityReporter = activityReporter
        super.init()

        notificationCenter.delegate = self
        registerNotificationAction()

        remoteDeviceTokenPublisher.catch { _ in
            return Empty()
        }.sink { [weak self] data in
            self?.deviceToken = data
        }.store(in: &cancellables)
    }

        func registerForRemoteNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                guard settings.authorizationStatus == .authorized else { return }
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }

    func remoteDeviceTokenPublisher() -> AnyPublisher<Data, Never> {
        return $deviceToken.compactMap { $0 }.eraseToAnyPublisher()
    }

    private func registerNotificationAction() {
                let approveAction = UNNotificationAction(identifier: NotificationAction.approve.rawValue,
                                                 title: L10n.Localizable.pushAcceptButtonTitle,
                                                 options: [.authenticationRequired])
        let denyAction = UNNotificationAction(identifier: NotificationAction.deny.rawValue,
                                              title: L10n.Localizable.pushRejectButtonTitle,
                                              options: [.destructive, .authenticationRequired])
        let authenticationRequestCategory =
            UNNotificationCategory(identifier: NotificationActionCategory.authenticationRequest.rawValue,
              actions: [approveAction, denyAction],
              intentIdentifiers: [],
              hiddenPreviewsBodyPlaceholder: "",
              options: .customDismissAction)
                let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.setNotificationCategories([authenticationRequestCategory])
    }
}

extension NotificationService: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if UIApplication.shared.applicationState == .active {
            let userInfo = notification.request.content.userInfo
            guard let authenticationRequest = AuthenticationRequest(userInfo: userInfo) else {
                remoteNotificationPublisher.send(.welcome)
                return
            }
            activityReporter.report(UserEvent.AuthenticatorPushAction(authenticatorPushStatus: .received, authenticatorPushType: .otpCode))
            remoteNotificationPublisher.send(.requestAuthentication(authenticationRequest))
        } else {
            activityReporter.report(UserEvent.AuthenticatorPushAction(authenticatorPushStatus: .received, authenticatorPushType: .otpCode))
            completionHandler([.badge, .banner, .list, .sound])
        }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let action = NotificationAction(rawValue: response.actionIdentifier)
        let notification = response.notification

        let userInfo = notification.request.content.userInfo
        guard let authenticationRequest = AuthenticationRequest(userInfo: userInfo) else {
            return
        }

                if let action = action {
            Task(priority: .userInitiated) {
                do {
                    if action == .approve {
                        try await accept(authenticationRequest)
                    } else {
                        try await reject(authenticationRequest)
                    }
                    await MainActor.run {
                        completionHandler()
                    }
                } catch {
                    await MainActor.run {
                        completionHandler()
                    }
                }
            }
        } else {
            remoteNotificationPublisher.send(.requestAuthentication(authenticationRequest))
        }
    }

    public func accept(_ request: AuthenticationRequest) async throws {
        guard let deviceAccessKey = try? sessionsContainer.info(for: Login(request.login)).deviceAccessKey else {
            return
        }
        try await self.apiClient.validateRequest(with: ValidateRequestInfo(requestId: request.requestId,
                                                                  approval: Approval(status: .approved, isSuspicious: nil),
                                                                  deviceAccessKey: deviceAccessKey))
        activityReporter.report(UserEvent.AuthenticatorPushAction(authenticatorPushStatus: .accepted, authenticatorPushType: .otpCode))
    }

    public func reject(_ request: AuthenticationRequest) async throws {
        guard let deviceAccessKey = try? sessionsContainer.info(for: Login(request.login)).deviceAccessKey else {
            return
        }
        try await self.apiClient.validateRequest(with: ValidateRequestInfo(requestId: request.requestId,
                                                                  approval: Approval(status: .rejected, isSuspicious: false),
                                                                  deviceAccessKey: deviceAccessKey))
        activityReporter.report(UserEvent.AuthenticatorPushAction(authenticatorPushStatus: .rejected, authenticatorPushType: .otpCode))
    }
}

class NotificationServiceMock: NotificationServiceProtocol {

    var remoteNotificationPublisher = CurrentValueSubject<Notification?, Never>(nil)

    func accept(_ request: AuthenticationRequest) async throws {}

    func reject(_ request: AuthenticationRequest) async throws {}

}
