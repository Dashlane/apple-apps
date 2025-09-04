import Foundation

public enum TeamAuditLogError: Error {
  case noBusinessTeamEnabledCollection
  case unsupportedDataType
  case nonBusinessItem
}
