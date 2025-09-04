import CorePersonalData
import CoreTeamAuditLogs
import DashlaneAPI
import Foundation

extension CreditCard: AuditLogReportableItem {

  public func generateReportableInfo(with context: AuditLogContext) -> ReportableInfo? {
    guard let spaceId, !spaceId.isEmpty else {
      return nil
    }
    switch context {
    case .create, .update, .delete, .autofill, .passkeyLogin, .userExcludedItemPH,
      .userIncludedItemPH:
      return nil
    case .reveal(let field):
      guard let field else {
        return nil
      }
      return ReportableInfo(
        log: TeamAuditLog(
          logType: .userRevealedCreditCardField,
          properties: .init(field: field, name: name)),
        spaceId: spaceId)
    case .copy(let field):
      guard let field else {
        return nil
      }
      return ReportableInfo(
        log: TeamAuditLog(
          logType: .userCopiedCreditCardField,
          properties: .init(field: field, name: name)),
        spaceId: spaceId)
    }
  }
}
