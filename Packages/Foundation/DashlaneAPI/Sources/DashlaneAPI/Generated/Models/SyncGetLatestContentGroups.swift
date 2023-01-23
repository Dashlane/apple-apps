import Foundation

public struct SyncGetLatestContentGroups: Codable, Equatable {

    public let id: String

    public let revision: Int

    public init(id: String, revision: Int) {
        self.id = id
        self.revision = revision
    }
}
