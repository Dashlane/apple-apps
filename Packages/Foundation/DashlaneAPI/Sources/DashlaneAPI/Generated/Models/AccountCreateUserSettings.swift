import Foundation

public struct AccountCreateUserSettings: Codable, Equatable {

        public let content: String

        public let time: Int

    public init(content: String, time: Int) {
        self.content = content
        self.time = time
    }
}
