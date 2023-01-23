import Foundation

extension Definition {

public enum `RemoteFileUpdateError`: String, Encodable {
case `decipherError` = "decipher_error"
case `downloadError` = "download_error"
case `localStorageError` = "local_storage_error"
case `otherError` = "other_error"
case `serverError` = "server_error"
}
}