import Foundation
import DashTypes

extension DatabaseReader {
    func fetchOneForSharing(with id: Identifier) throws -> PersonalDataRecord? {
        guard let record = try fetchOne(with: id),
              record.metadata.syncStatus != .pendingRemove else {
                  return nil
              }

        return record
    }

    func fetchOneMetadataForSharing(with id: Identifier) throws -> RecordMetadata? {
        guard let metadata = try fetchOneMetadata(with: id),
              metadata.syncStatus != .pendingRemove else {
                  return nil
              }

        return metadata
    }
}
