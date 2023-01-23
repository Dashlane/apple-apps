import Foundation

extension Definition {

public enum `CryptoMigrationStatus`: String, Encodable {
case `errorDownload` = "error_download"
case `errorReencryption` = "error_reencryption"
case `errorUpdateLocalData` = "error_update_local_data"
case `errorUpload` = "error_upload"
case `success`
}
}