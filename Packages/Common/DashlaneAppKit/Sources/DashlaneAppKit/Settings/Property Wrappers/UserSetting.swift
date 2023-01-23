import Foundation
import CoreSettings

@propertyWrapper
public struct UserSetting<T: DataConvertible> {
    private let key: UserSettingsKey
    private let settings: UserSettings
    private let didSetAction: ((T) -> Void)?

    public init(key: UserSettingsKey, settings: UserSettings, defaultValue: T, onDidSet didSetAction: ((T) -> Void)? = nil) {
        self.key = key
        self.settings = settings
        wrappedValue = settings[key] ?? defaultValue
        self.didSetAction = didSetAction
    }

    public var wrappedValue: T {
        didSet {
            settings[key] = wrappedValue
            didSetAction?(wrappedValue)
        }
    }
}
