import Foundation

public enum SettingRegistrationError: Error {
    case alreadyRegistered(identifier: String)
}

public struct SettingRegistration {
    public let identifier: String
    public let type: Any.Type
    public let secure: Bool

    public init(identifier: String, type: Any.Type, secure: Bool = false) {
        self.identifier = identifier
        self.type = type
        self.secure = secure
    }
}

public final class SettingsRegister {

    private let queue = DispatchQueue(label: "settings")

    private var dSettings = [String: SettingRegistration]()

                public func append(_ settingRegistrations: SettingRegistration...) throws {
        try self.append(settingRegistrations)
    }

        public func append(_ settingRegistrations: [SettingRegistration]) throws {
        try queue.sync {
            for settingRegistration in settingRegistrations where dSettings[settingRegistration.identifier] != nil {
                throw SettingRegistrationError.alreadyRegistered(identifier: settingRegistration.identifier)
            }
            settingRegistrations.forEach {
                dSettings[$0.identifier] = $0
            }
        }
    }

    public func isRegistered(identifier: String) -> Bool {
        return queue.sync { self[identifier] != nil }
    }

    public subscript(identifier: String) -> SettingRegistration? {
        return queue.sync { dSettings[identifier] }
    }

}
