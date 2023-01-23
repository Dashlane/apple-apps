import Foundation

public struct AppCredentials {
    public let accessKey: String
    public let secretKey: String

    public init(accessKey: String, secretKey: String) {
        self.accessKey = accessKey
        self.secretKey = secretKey
    }
}

public struct UserCredentials {
    public let login: String
    public let deviceAccessKey: String
    public let deviceSecretKey: String

    public init(login: String, deviceAccessKey: String, deviceSecretKey: String) {
        self.login = login
        self.deviceAccessKey = deviceAccessKey
        self.deviceSecretKey = deviceSecretKey
    }
}
