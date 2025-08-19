import Foundation

public enum SyncDataAction: String, Sendable, Hashable, Codable, CaseIterable {
  case backupEdit = "BACKUP_EDIT"
  case undecodable
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let rawValue = try container.decode(String.self)
    self = Self(rawValue: rawValue) ?? .undecodable
  }
}
