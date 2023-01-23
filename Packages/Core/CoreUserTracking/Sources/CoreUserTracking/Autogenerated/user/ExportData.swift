import Foundation

extension UserEvent {

public struct `ExportData`: Encodable, UserEventProtocol {
public static let isPriority = false
public init(`backupFileType`: Definition.BackupFileType) {
self.backupFileType = backupFileType
}
public let backupFileType: Definition.BackupFileType
public let name = "export_data"
}
}
