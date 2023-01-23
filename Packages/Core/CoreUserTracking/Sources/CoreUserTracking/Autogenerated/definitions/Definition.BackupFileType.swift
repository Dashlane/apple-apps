import Foundation

extension Definition {

public enum `BackupFileType`: String, Encodable {
case `csv`
case `secureVault` = "secure_vault"
case `unknown`
}
}