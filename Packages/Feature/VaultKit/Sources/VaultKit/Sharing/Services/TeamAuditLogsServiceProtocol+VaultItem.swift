import CorePersonalData
import CoreTeamAuditLogs
import CoreTypes
import DashlaneAPI

extension TeamAuditLogsServiceProtocol {
  func auditLogDetails(for item: VaultItem) async throws -> AuditLogDetails? {
    try await auditLogDetails(for: [item]).first?.value
  }

  func auditLogDetails(for items: [VaultItem]) async throws -> [Identifier: AuditLogDetails] {
    try await auditLogDetails(for: items.makeTeamAuditLogs())
  }
}

extension VaultItem {
  func makeTeamAuditLog() -> TeamVaultAuditLog? {
    guard let spaceId = self.spaceId, let data = makeTeamAuditLogData() else {
      return nil
    }

    return TeamVaultAuditLog(spaceId: spaceId, data: data)
  }

  func makeTeamAuditLogData() -> TeamVaultAuditLog.AuditData? {
    switch self.enumerated {
    case let .credential(credential) where credential.url?.domain != nil:
      guard let domain = credential.url?.domain?.name else {
        return nil
      }

      return .credential(domain: domain)
    default:
      return nil
    }
  }
}

extension [any VaultItem] {
  fileprivate func makeTeamAuditLogs() -> [Identifier: TeamVaultAuditLog] {
    var auditLogs = [Identifier: TeamVaultAuditLog]()
    for item in self {
      guard let auditLog = item.makeTeamAuditLog() else {
        continue
      }

      auditLogs[item.id] = auditLog
    }

    return auditLogs
  }
}
