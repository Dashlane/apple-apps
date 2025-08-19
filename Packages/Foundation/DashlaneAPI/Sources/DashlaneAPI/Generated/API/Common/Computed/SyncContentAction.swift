import Foundation

public enum SyncContentAction: String, Sendable, Hashable, Codable, CaseIterable {
  case backupEdit = "BACKUP_EDIT"
  case backupRemove = "BACKUP_REMOVE"
  case undecodable
  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    let rawValue = try container.decode(String.self)
    self = Self(rawValue: rawValue) ?? .undecodable
  }
}
