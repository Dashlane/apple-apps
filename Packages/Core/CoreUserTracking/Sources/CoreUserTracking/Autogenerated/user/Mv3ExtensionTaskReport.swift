import Foundation

extension UserEvent {

  public struct `Mv3ExtensionTaskReport`: Encodable, UserEventProtocol {
    public static let isPriority = false
    public init(
      `businessDomain`: Definition.BusinessDomain, `feature`: String,
      `hasWokenUpServiceWorker`: Bool? = nil, `serviceWorkerInterruptionCount`: Int,
      `serviceWorkerStartDateTime`: Date, `taskEndDateTime`: Date, `taskName`: String,
      `taskStartDateTime`: Date
    ) {
      self.businessDomain = businessDomain
      self.feature = feature
      self.hasWokenUpServiceWorker = hasWokenUpServiceWorker
      self.serviceWorkerInterruptionCount = serviceWorkerInterruptionCount
      self.serviceWorkerStartDateTime = serviceWorkerStartDateTime
      self.taskEndDateTime = taskEndDateTime
      self.taskName = taskName
      self.taskStartDateTime = taskStartDateTime
    }
    public let businessDomain: Definition.BusinessDomain
    public let feature: String
    public let hasWokenUpServiceWorker: Bool?
    public let name = "mv3_extension_task_report"
    public let serviceWorkerInterruptionCount: Int
    public let serviceWorkerStartDateTime: Date
    public let taskEndDateTime: Date
    public let taskName: String
    public let taskStartDateTime: Date
  }
}
