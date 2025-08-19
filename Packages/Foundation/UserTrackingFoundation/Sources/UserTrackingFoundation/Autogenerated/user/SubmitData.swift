import Foundation

extension UserEvent {

  public struct `SubmitData`: Encodable, UserEventProtocol {
    public static let isPriority = false
    public init(
      `itemCount`: Int? = nil, `itemSource`: Definition.BackupFileType,
      `itemType`: Definition.DataSource,
      `submitStep`: Definition.TransferDataStatus
    ) {
      self.itemCount = itemCount
      self.itemSource = itemSource
      self.itemType = itemType
      self.submitStep = submitStep
    }
    public let itemCount: Int?
    public let itemSource: Definition.BackupFileType
    public let itemType: Definition.DataSource
    public let name = "submit_data"
    public let submitStep: Definition.TransferDataStatus
  }
}
