import CorePersonalData
import CoreTeamAuditLogs
import DashlaneAPI
import Foundation

extension SecureNote: AuditLogReportableItem {

  public func generateReportableInfo(with context: AuditLogContext) -> ReportableInfo? {
    guard let spaceId, !spaceId.isEmpty else {
      return nil
    }
    switch context {
    case .create, .update, .delete, .reveal, .autofill, .passkeyLogin, .userExcludedItemPH,
      .userIncludedItemPH:
      return nil
    case .copy:
      return ReportableInfo(
        log: TeamAuditLog(
          logType: .userCopiedSecureNoteField,
          properties: .init(name: title)),
        spaceId: spaceId)
    }
  }
}
