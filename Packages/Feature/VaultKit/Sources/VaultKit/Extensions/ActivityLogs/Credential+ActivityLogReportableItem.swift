import CorePersonalData
import CoreTeamAuditLogs
import DashlaneAPI
import Foundation

extension Credential: AuditLogReportableItem {

  public func generateReportableInfo(with context: AuditLogContext) -> ReportableInfo? {
    guard let spaceId, !spaceId.isEmpty else {
      return nil
    }
    switch context {
    case .create:
      return ReportableInfo(
        log: TeamAuditLog(
          logType: .userCreatedCredential,
          properties: .init(domainURL: url?.displayDomain ?? title)),
        spaceId: spaceId)
    case .update:
      return ReportableInfo(
        log: TeamAuditLog(
          logType: .userModifiedCredential,
          properties: .init(domainURL: url?.displayDomain ?? title)),
        spaceId: spaceId)
    case .delete:
      return ReportableInfo(
        log: TeamAuditLog(
          logType: .userDeletedCredential,
          properties: .init(domainURL: url?.displayDomain ?? title)),
        spaceId: spaceId)
    case .reveal(let field):
      guard let field else {
        return nil
      }
      return ReportableInfo(
        log: TeamAuditLog(
          logType: .userRevealedCredentialField,
          properties: .init(
            credentialDomain: url?.displayDomain ?? title,
            credentialLogin: login.isEmpty ? email : login,
            field: field)),
        spaceId: spaceId)
    case .copy(let field):
      guard let field else {
        return nil
      }
      return ReportableInfo(
        log: TeamAuditLog(
          logType: .userCopiedCredentialField,
          properties: .init(
            credentialDomain: url?.displayDomain ?? title,
            credentialLogin: login.isEmpty ? email : login,
            field: field)),
        spaceId: spaceId)
    case .autofill(let autofilledDomain):
      return ReportableInfo(
        log: TeamAuditLog(
          logType: .userPerformedAutofillCredential,
          properties: .init(
            autofilledDomain: autofilledDomain, credentialDomain: url?.displayDomain ?? title,
            credentialLogin: login.isEmpty ? email : login)),
        spaceId: spaceId)
    case .passkeyLogin:
      return nil
    case .userExcludedItemPH:
      return ReportableInfo(
        log: TeamAuditLog(
          logType: .userExcludedItemFromPasswordHealth,
          properties: .init(
            credentialDomain: url?.displayDomain ?? title,
            credentialLogin: login.isEmpty ? email : login)), spaceId: spaceId)
    case .userIncludedItemPH:
      return ReportableInfo(
        log: TeamAuditLog(
          logType: .userIncludedItemInPasswordHealth,
          properties: .init(
            credentialDomain: url?.displayDomain ?? title,
            credentialLogin: login.isEmpty ? email : login)), spaceId: spaceId)
    }
  }
}
