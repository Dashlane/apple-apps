import Foundation

public struct SyncUploadDataRemoteKeys: Codable, Equatable {

    private enum CodingKeys: String, CodingKey {
        case uuid = "uuid"
        case key = "key"
        case type = "type"
    }

    public let uuid: String

    public let key: String

    public let type: SyncUploadDataType

    public init(uuid: String, key: String, type: SyncUploadDataType) {
        self.uuid = uuid
        self.key = key
        self.type = type
    }
}
