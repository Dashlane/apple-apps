import Foundation

public struct SyncGetLatestContentGroups: Codable, Equatable {

    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case revision = "revision"
    }

    public let id: String

    public let revision: Int

    public init(id: String, revision: Int) {
        self.id = id
        self.revision = revision
    }
}
