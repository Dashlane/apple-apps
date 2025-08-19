import Foundation

public protocol AuditLogReportableItem {
  func generateReportableInfo(with context: AuditLogContext) -> ReportableInfo?
}

public enum AuditLogContext {
  case create
  case update
  case delete
  case reveal(
    field: UserSecureNitroEncryptionAPIClient.Logs.StoreAuditLogs.Body.AuditLogsElement.Properties
      .Field?)
  case copy(
    field: UserSecureNitroEncryptionAPIClient.Logs.StoreAuditLogs.Body.AuditLogsElement.Properties
      .Field?)
  case autofill(autofilledDomain: String)
  case passkeyLogin(currentDomain: String, credentialLogin: String)
  case userExcludedItemPH
  case userIncludedItemPH
}
