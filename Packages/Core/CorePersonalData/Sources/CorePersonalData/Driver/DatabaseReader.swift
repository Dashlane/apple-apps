import Combine
import DashTypes
import Foundation

public protocol DatabaseReader {
  func fetchAll(with ids: [Identifier]) throws -> [PersonalDataRecord]
  func fetchAllSnapshots(with ids: [Identifier]) throws -> [PersonalDataSnapshot]
  func fetchAll(by kind: PersonalDataContentType) throws -> [PersonalDataRecord]
  func fetchAll(by status: RecordMetadata.SyncStatus) throws -> [PersonalDataRecord]
  func fetchAllPendingSharingUpload() throws -> [PersonalDataRecord]

  func fetchAllMetadata() throws -> [RecordMetadata]
  func fetchAllMetadata(with ids: [Identifier]) throws -> [RecordMetadata]

  func fetchOne(with id: Identifier) throws -> PersonalDataRecord?
  func fetchOneSnapshot(with id: Identifier) throws -> PersonalDataSnapshot?
  func fetchOne(withSharingId: String) throws -> PersonalDataRecord?
  func fetchOne(withParentId id: Identifier) throws -> PersonalDataRecord?

  func fetchOneMetadata(with id: Identifier) throws -> RecordMetadata?
  func fetchOneMetadata(withSyncRequestId id: String) throws -> RecordMetadata?

  func count(for kind: PersonalDataContentType) throws -> Int
}
