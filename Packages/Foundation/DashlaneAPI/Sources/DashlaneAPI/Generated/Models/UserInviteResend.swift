import Foundation

public struct UserInviteResend: Codable, Equatable {

        public let userId: String

        public let alias: String

    public init(userId: String, alias: String) {
        self.userId = userId
        self.alias = alias
    }
}
