import DashlaneAPI
import Foundation

public protocol ActivityLogReportableItem {
  func reportableInfo() -> ActivityLogReportableInfo?
}

public struct ActivityLogReportableInfo: Equatable {
  public let spaceId: String?
  public let createdItemActivityLog: ActivityLog.LogType
  public let updatedItemActivityLog: ActivityLog.LogType
  public let deletedItemActivityLog: ActivityLog.LogType
  public let properties: ActivityLog.Properties

  public init(
    spaceId: String?,
    createdItemActivityLog: ActivityLog.LogType,
    updatedItemActivityLog: ActivityLog.LogType,
    deletedItemActivityLog: ActivityLog.LogType,
    properties: ActivityLog.Properties
  ) {
    self.spaceId = spaceId
    self.createdItemActivityLog = createdItemActivityLog
    self.updatedItemActivityLog = updatedItemActivityLog
    self.deletedItemActivityLog = deletedItemActivityLog
    self.properties = properties
  }
}

extension ActivityLogReportableInfo {
  func logType(for action: ActivityLogsService.ItemAction) -> ActivityLog.LogType {
    switch action {
    case .creation:
      return createdItemActivityLog
    case .update:
      return updatedItemActivityLog
    case .deletion:
      return deletedItemActivityLog
    }
  }
}
