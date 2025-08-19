import Foundation

extension Definition {

  public enum `BackupFileType`: String, Encodable, Sendable {
    case `applePasswords` = "apple_passwords"
    case `credentialExchangeProtocol` = "credential_exchange_protocol"
    case `csv`
    case `dash`
    case `manualInput` = "manual_input"
    case `pendingSelection` = "pending_selection"
    case `secureVault` = "secure_vault"
    case `txt`
    case `unknown`
  }
}
