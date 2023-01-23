import Foundation

extension UserEvent {

public struct `ImportData`: Encodable, UserEventProtocol {
public static let isPriority = false
public init(`backupFileType`: Definition.BackupFileType, `importDataStatus`: Definition.ImportDataStatus, `importSource`: Definition.ImportSource, `importedItemsCount`: Int? = nil, `itemsToImportCount`: Int? = nil, `space`: Definition.Space? = nil) {
self.backupFileType = backupFileType
self.importDataStatus = importDataStatus
self.importSource = importSource
self.importedItemsCount = importedItemsCount
self.itemsToImportCount = itemsToImportCount
self.space = space
}
public let backupFileType: Definition.BackupFileType
public let importDataStatus: Definition.ImportDataStatus
public let importSource: Definition.ImportSource
public let importedItemsCount: Int?
public let itemsToImportCount: Int?
public let name = "import_data"
public let space: Definition.Space?
}
}
