import CorePersonalData
import CoreTeamAuditLogs
import DashlaneAPI

extension TeamAuditLogsServiceProtocol {

  func logSave(_ item: VaultItem) {
    try? report(
      item.generateReportableInfo(with: item.isSaved ? .update : .create)
    )
  }

  func logSave(_ items: [VaultItem]) {
    for item in items {
      logSave(item)
    }
  }

  func logDelete(_ item: VaultItem) {
    try? report(
      item.generateReportableInfo(with: .delete)
    )
  }

  func logReveal(
    _ item: VaultItem,
    field: UserSecureNitroEncryptionAPIClient.Logs.StoreAuditLogs.Body.AuditLogsElement.Properties
      .Field?
  ) {
    try? report(
      item.generateReportableInfo(with: .reveal(field: field))
    )
  }

  func logCopy(
    _ item: VaultItem,
    field: UserSecureNitroEncryptionAPIClient.Logs.StoreAuditLogs.Body.AuditLogsElement.Properties
      .Field?
  ) {
    try? report(
      item.generateReportableInfo(with: .copy(field: field))
    )
  }

  public func logAutofillCredential(_ item: VaultItem, autofilledDomain: String) {
    try? report(
      item.generateReportableInfo(with: .autofill(autofilledDomain: autofilledDomain))
    )
  }

  public func logPasskeyLogin(_ item: VaultItem, currentDomain: String, credentialLogin: String) {
    try? report(
      item.generateReportableInfo(
        with: .passkeyLogin(currentDomain: currentDomain, credentialLogin: credentialLogin))
    )
  }
}
