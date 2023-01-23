import Foundation
import DashlaneAppKit
import CoreSettings
import Combine

public protocol NotificationActionHandler {
    func dismiss()
    func reportAsDisplayed()
    func reportClick()
}

struct NotificationSettings: NotificationActionHandler {
    fileprivate enum SettingsKey: String, LocalSettingsKey {
        case hasBeenDisplayed
        case hasBeenDismissed
        case creationDate = "dateOfEligibility"

        var isEncrypted: Bool {
            false
        }

        var type: Any.Type {
            switch self {
            case .creationDate: return Date.self
            default: return Bool.self
            }
        }
    }

    private let prefix: String
    private let settings: KeyedSettings<SettingsKey>
    let creationDate: Date
    private let logger: NotificationCenterLogger

    init(prefix: String,
         settings: LocalSettingsStore,
         logger: NotificationCenterLogger) {
        self.prefix = prefix
        self.settings = KeyedSettings<SettingsKey>(internalStore: settings, withPrefix: prefix)
        self.logger = logger
                if self.settings[.creationDate] as Date? == nil {
            self.settings[.creationDate] = Date()
        }
        let creationDate = self.settings[.creationDate] as Date?
        self.creationDate = creationDate ?? Date()
    }

    func fetchState() -> NotificationCenterService.Notification.State {
        return settings.fetchState()
    }

    func settingsChangePublisher() -> AnyPublisher<Void, Never> {
        return settings
            .settingsChangePublisher
            .mapToVoid()
            .prepend(Void())
            .eraseToAnyPublisher()
    }

    func dismiss() {
        if settings[.hasBeenDismissed] != true {
            logger.log(subaction: .dismiss, for: prefix)
        }
        settings[.hasBeenDismissed] = true
    }

    func reportAsDisplayed() {
        if settings[.hasBeenDisplayed] != true {
            logger.log(subaction: .show, for: prefix)
        }
        settings[.hasBeenDisplayed] = true
    }

    func reportClick() {
        logger.log(subaction: .click, for: prefix)
    }
}

private extension KeyedSettings where Key == NotificationSettings.SettingsKey {
    func fetchState() -> NotificationCenterService.Notification.State {
        if self[.hasBeenDismissed] ?? false {
            return .dismissed
        } else if self[.hasBeenDisplayed] ?? false {
            return .seen
        } else {
            return .unseen
        }
    }
}

private struct FakeNotificationActionHandler: NotificationActionHandler {
    func dismiss() {}
    func reportAsDisplayed() {}
    func reportClick() {}
}

extension NotificationSettings {
    static var mock: NotificationActionHandler {
        FakeNotificationActionHandler()
    }
}
