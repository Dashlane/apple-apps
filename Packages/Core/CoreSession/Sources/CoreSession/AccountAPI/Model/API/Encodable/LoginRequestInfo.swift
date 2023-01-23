import Foundation
import DashTypes

public struct LoginRequestInfo: Encodable {
    public let login: String
    public let deviceAccessKey: String
    public let u2fSecret: String?
    public let profiles: [Profile]
    public let methods: [Login2FAOption]
    
    public init(login: String, deviceAccessKey: String, u2fSecret: String? = nil, loginsToCheckForDeletion: [Login] = [], methods: [Login2FAOption] = [.token, .totp, .duoPush, .authenticator]) {
        self.login = login
        self.deviceAccessKey = deviceAccessKey
        self.u2fSecret = u2fSecret
        self.methods = methods
        if loginsToCheckForDeletion.isEmpty {
            self.profiles = [Profile(login: login, deviceAccessKey: deviceAccessKey)]
        } else {
            self.profiles = loginsToCheckForDeletion.map {
                Profile(login: $0.email, deviceAccessKey: deviceAccessKey)
            }
        }
    }
}
