import DashTypes
import Foundation

extension PersonalDataDecoder {
  func decode(
    _ sharingType: SharingType, from record: PersonalDataRecord,
    using linkedFetcher: LinkedFetcher? = nil
  ) throws -> PersonalDataCodable {
    switch sharingType {
    case .password:
      return try decode(Credential.self, from: record, using: linkedFetcher)
    case .note:
      return try decode(SecureNote.self, from: record, using: linkedFetcher)
    case .secret:
      return try decode(Secret.self, from: record, using: linkedFetcher)
    }
  }
}
