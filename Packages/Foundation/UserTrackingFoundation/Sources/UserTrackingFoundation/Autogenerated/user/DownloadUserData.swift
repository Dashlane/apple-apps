import Foundation

extension UserEvent {

  public struct `DownloadUserData`: Encodable, UserEventProtocol {
    public static let isPriority = false
    public init(
      `dataSource`: Definition.DataSource, `fileType`: Definition.BackupFileType,
      `flowStep`: Definition.FlowStep
    ) {
      self.dataSource = dataSource
      self.fileType = fileType
      self.flowStep = flowStep
    }
    public let dataSource: Definition.DataSource
    public let fileType: Definition.BackupFileType
    public let flowStep: Definition.FlowStep
    public let name = "download_user_data"
  }
}
