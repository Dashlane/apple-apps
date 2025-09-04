import CorePersonalData
import CoreTeamAuditLogs
import DashlaneAPI
import Foundation

extension Passkey: AuditLogReportableItem {

  public func generateReportableInfo(with context: AuditLogContext) -> ReportableInfo? {
    guard let spaceId, !spaceId.isEmpty else {
      return nil
    }
    switch context {
    case .create, .update, .delete, .autofill, .reveal, .copy, .userExcludedItemPH,
      .userIncludedItemPH:
      return nil
    case let .passkeyLogin(currentDomain, credentialLogin):
      return ReportableInfo(
        log: TeamAuditLog(
          logType: .userAuthenticatedWithPasskey,
          properties: .init(
            credentialLogin: credentialLogin,
            currentDomain: currentDomain,
            passkeyDomain: domain)),
        spaceId: spaceId)
    }
  }

}
