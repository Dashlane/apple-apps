import Foundation

extension UserEvent {

public struct `ImportData`: Encodable, UserEventProtocol {
public static let isPriority = false
public init(`backupFileType`: Definition.BackupFileType, `importDataDropAction`: Definition.ImportDataDropAction? = nil, `importDataStatus`: Definition.ImportDataStatus, `importDataStep`: Definition.ImportDataStep, `importSource`: Definition.ImportSource, `importedItemsCount`: Int? = nil, `isDirectImport`: Bool, `itemsToImportCount`: Int? = nil, `space`: Definition.Space? = nil) {
self.backupFileType = backupFileType
self.importDataDropAction = importDataDropAction
self.importDataStatus = importDataStatus
self.importDataStep = importDataStep
self.importSource = importSource
self.importedItemsCount = importedItemsCount
self.isDirectImport = isDirectImport
self.itemsToImportCount = itemsToImportCount
self.space = space
}
public let backupFileType: Definition.BackupFileType
public let importDataDropAction: Definition.ImportDataDropAction?
public let importDataStatus: Definition.ImportDataStatus
public let importDataStep: Definition.ImportDataStep
public let importSource: Definition.ImportSource
public let importedItemsCount: Int?
public let isDirectImport: Bool
public let itemsToImportCount: Int?
public let name = "import_data"
public let space: Definition.Space?
}
}
