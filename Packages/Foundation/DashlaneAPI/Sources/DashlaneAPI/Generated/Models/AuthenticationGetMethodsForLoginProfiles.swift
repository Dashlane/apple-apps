import Foundation

public struct AuthenticationGetMethodsForLoginProfiles: Codable, Equatable {

    private enum CodingKeys: String, CodingKey {
        case login = "login"
        case deviceAccessKey = "deviceAccessKey"
    }

        public let login: String

        public let deviceAccessKey: String

    public init(login: String, deviceAccessKey: String) {
        self.login = login
        self.deviceAccessKey = deviceAccessKey
    }
}
