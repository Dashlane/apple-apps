import Foundation

public struct AccountCreateUserSettings: Codable, Equatable {

    private enum CodingKeys: String, CodingKey {
        case content = "content"
        case time = "time"
    }

        public let content: String

        public let time: Int

    public init(content: String, time: Int) {
        self.content = content
        self.time = time
    }
}
