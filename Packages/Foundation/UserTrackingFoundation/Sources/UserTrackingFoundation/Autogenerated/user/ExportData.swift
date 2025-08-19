import Foundation

extension UserEvent {

  public struct `ExportData`: Encodable, UserEventProtocol {
    public static let isPriority = false
    public init(
      `backupFileType`: Definition.BackupFileType,
      `exportDataStatus`: Definition.TransferDataStatus,
      `exportDataStep`: Definition.TransferDataStep,
      `exportDestination`: Definition.TransferDataSource? = nil,
      `exportedItemsCount`: Int? = nil, `itemsToExportCount`: Int? = nil
    ) {
      self.backupFileType = backupFileType
      self.exportDataStatus = exportDataStatus
      self.exportDataStep = exportDataStep
      self.exportDestination = exportDestination
      self.exportedItemsCount = exportedItemsCount
      self.itemsToExportCount = itemsToExportCount
    }
    public let backupFileType: Definition.BackupFileType
    public let exportDataStatus: Definition.TransferDataStatus
    public let exportDataStep: Definition.TransferDataStep
    public let exportDestination: Definition.TransferDataSource?
    public let exportedItemsCount: Int?
    public let itemsToExportCount: Int?
    public let name = "export_data"
  }
}
