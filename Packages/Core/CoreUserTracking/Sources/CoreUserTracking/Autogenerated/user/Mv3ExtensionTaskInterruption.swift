import Foundation

extension UserEvent {

  public struct `Mv3ExtensionTaskInterruption`: Encodable, UserEventProtocol {
    public static let isPriority = false
    public init(
      `businessDomain`: Definition.BusinessDomain, `feature`: String,
      `serviceWorkerStartDateTime`: Date, `taskName`: String, `taskStartDateTime`: Date
    ) {
      self.businessDomain = businessDomain
      self.feature = feature
      self.serviceWorkerStartDateTime = serviceWorkerStartDateTime
      self.taskName = taskName
      self.taskStartDateTime = taskStartDateTime
    }
    public let businessDomain: Definition.BusinessDomain
    public let feature: String
    public let name = "mv3_extension_task_interruption"
    public let serviceWorkerStartDateTime: Date
    public let taskName: String
    public let taskStartDateTime: Date
  }
}
