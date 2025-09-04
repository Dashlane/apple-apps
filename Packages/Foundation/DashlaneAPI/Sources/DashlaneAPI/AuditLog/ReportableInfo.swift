import Foundation

public struct ReportableInfo {
  public let log: TeamAuditLog
  public let spaceId: String?

  public init(log: TeamAuditLog, spaceId: String?) {
    self.log = log
    self.spaceId = spaceId
  }
}
