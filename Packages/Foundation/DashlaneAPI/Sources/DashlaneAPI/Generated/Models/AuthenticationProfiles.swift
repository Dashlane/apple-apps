import Foundation

public struct AuthenticationProfiles: Codable, Equatable {

        public let login: String

        public let deviceAccessKey: String

    public init(login: String, deviceAccessKey: String) {
        self.login = login
        self.deviceAccessKey = deviceAccessKey
    }
}
