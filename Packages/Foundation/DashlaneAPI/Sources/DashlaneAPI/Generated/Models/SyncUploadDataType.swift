import Foundation

public enum SyncUploadDataType: String, Codable, Equatable, CaseIterable {
    case sso = "sso"
    case masterPassword = "master_password"
}
