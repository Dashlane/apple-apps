import Foundation

public struct DarkwebmonitoringListEmails: Codable, Equatable {

    public let email: String

    public let state: String

    public let expiresIn: Int?

    public init(email: String, state: String, expiresIn: Int? = nil) {
        self.email = email
        self.state = state
        self.expiresIn = expiresIn
    }
}
