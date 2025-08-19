import Foundation

extension Definition {

  public enum `TransferDataStep`: String, Encodable, Sendable {
    case `credentialExchangeProtocol` = "credential_exchange_protocol"
    case `decryptLastpassVault` = "decrypt_lastpass_vault"
    case `importingFile` = "importing_file"
    case `loginToLastpass` = "login_to_lastpass"
    case `previewItemsToExport` = "preview_items_to_export"
    case `previewItemsToImport` = "preview_items_to_import"
    case `selectDashlaneSpace` = "select_dashlane_space"
    case `selectExportDestination` = "select_export_destination"
    case `selectFile` = "select_file"
    case `selectImportSource` = "select_import_source"
    case `success`
  }
}
