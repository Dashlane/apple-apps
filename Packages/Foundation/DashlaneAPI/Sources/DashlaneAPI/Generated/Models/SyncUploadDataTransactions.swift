import Foundation

public struct SyncUploadDataTransactions: Codable, Equatable {

    private enum CodingKeys: String, CodingKey {
        case identifier = "identifier"
        case time = "time"
        case content = "content"
        case type = "type"
        case action = "action"
    }

        public let identifier: String

        public let time: Int

        public let content: String

        public let type: String

    public let action: SyncDataAction

    public init(identifier: String, time: Int, content: String, type: String, action: SyncDataAction) {
        self.identifier = identifier
        self.time = time
        self.content = content
        self.type = type
        self.action = action
    }
}
