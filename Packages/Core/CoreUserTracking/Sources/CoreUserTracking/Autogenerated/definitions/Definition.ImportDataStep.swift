import Foundation

extension Definition {

public enum `ImportDataStep`: String, Encodable {
case `decryptLastpassVault` = "decrypt_lastpass_vault"
case `loginToLastpass` = "login_to_lastpass"
case `previewItemsToImport` = "preview_items_to_import"
case `selectDashlaneSpace` = "select_dashlane_space"
case `selectFile` = "select_file"
case `selectImportSource` = "select_import_source"
case `success`
}
}