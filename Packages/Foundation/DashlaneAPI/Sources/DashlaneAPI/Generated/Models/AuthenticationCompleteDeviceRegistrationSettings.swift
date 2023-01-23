import Foundation

public struct AuthenticationCompleteDeviceRegistrationSettings: Codable, Equatable {

        public let backupDate: Int

        public let identifier: String

        public let time: Int

        public let content: String

    public let type: Empty?

    public let action: AuthenticationCompleteDeviceRegistrationAction

    public init(backupDate: Int, identifier: String, time: Int, content: String, type: Empty?, action: AuthenticationCompleteDeviceRegistrationAction) {
        self.backupDate = backupDate
        self.identifier = identifier
        self.time = time
        self.content = content
        self.type = type
        self.action = action
    }
}
