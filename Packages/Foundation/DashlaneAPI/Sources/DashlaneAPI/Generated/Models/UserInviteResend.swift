import Foundation

public struct UserInviteResend: Codable, Equatable {

    private enum CodingKeys: String, CodingKey {
        case userId = "userId"
        case alias = "alias"
    }

        public let userId: String

        public let alias: String

    public init(userId: String, alias: String) {
        self.userId = userId
        self.alias = alias
    }
}
