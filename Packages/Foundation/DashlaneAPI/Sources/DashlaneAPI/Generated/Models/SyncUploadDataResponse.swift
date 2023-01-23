import Foundation

public struct SyncUploadDataResponse: Codable, Equatable {

        public let timestamp: Int

    public init(timestamp: Int) {
        self.timestamp = timestamp
    }
}
