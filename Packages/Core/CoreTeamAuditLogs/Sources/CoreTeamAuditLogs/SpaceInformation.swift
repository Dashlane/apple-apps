import Foundation

public struct SpaceInformation {
  let id: String
  let collectSensitiveDataAuditLogsEnabled: Bool

  public init(id: String, collectSensitiveDataAuditLogsEnabled: Bool) {
    self.id = id
    self.collectSensitiveDataAuditLogsEnabled = collectSensitiveDataAuditLogsEnabled
  }
}
