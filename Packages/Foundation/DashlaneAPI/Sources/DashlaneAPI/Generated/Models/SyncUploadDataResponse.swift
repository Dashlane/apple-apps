import Foundation

public struct SyncUploadDataResponse: Codable, Equatable {

    private enum CodingKeys: String, CodingKey {
        case timestamp = "timestamp"
    }

        public let timestamp: Int

    public init(timestamp: Int) {
        self.timestamp = timestamp
    }
}
