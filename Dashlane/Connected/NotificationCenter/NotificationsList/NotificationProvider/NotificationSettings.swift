import Foundation
import DashlaneAppKit
import CoreSettings
import Combine

public protocol NotificationActionHandler {
    func dismiss()
    func reportAsDisplayed()
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

    init(prefix: String,
         settings: LocalSettingsStore) {
        self.prefix = prefix
        self.settings = KeyedSettings<SettingsKey>(internalStore: settings, withPrefix: prefix)
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
        settings[.hasBeenDismissed] = true
    }

    func reportAsDisplayed() {
        settings[.hasBeenDisplayed] = true
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
}

extension NotificationSettings {
    static var mock: NotificationActionHandler {
        FakeNotificationActionHandler()
    }
}
