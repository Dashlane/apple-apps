import Foundation

extension UserEvent {

  public struct `Sync`: Encodable, UserEventProtocol {
    public static let isPriority = false
    public init(
      `deduplicates`: Int? = nil, `duration`: Definition.Duration, `error`: Definition.Error? = nil,
      `errorDescription`: Definition.ErrorDescription? = nil,
      `errorName`: Definition.ErrorName? = nil, `errorStep`: Definition.ErrorStep? = nil,
      `extent`: Definition.Extent, `fullBackupSize`: Int? = nil, `incomingDeleteCount`: Int? = nil,
      `incomingUpdateCount`: Int? = nil, `itemGroupId`: String? = nil,
      `outgoingDeleteCount`: Int? = nil, `outgoingUpdateCount`: Int? = nil, `timestamp`: Int,
      `treatProblem`: Definition.TreatProblem? = nil, `trigger`: Definition.Trigger
    ) {
      self.deduplicates = deduplicates
      self.duration = duration
      self.error = error
      self.errorDescription = errorDescription
      self.errorName = errorName
      self.errorStep = errorStep
      self.extent = extent
      self.fullBackupSize = fullBackupSize
      self.incomingDeleteCount = incomingDeleteCount
      self.incomingUpdateCount = incomingUpdateCount
      self.itemGroupId = itemGroupId
      self.outgoingDeleteCount = outgoingDeleteCount
      self.outgoingUpdateCount = outgoingUpdateCount
      self.timestamp = timestamp
      self.treatProblem = treatProblem
      self.trigger = trigger
    }
    public let deduplicates: Int?
    public let duration: Definition.Duration
    public let error: Definition.Error?
    public let errorDescription: Definition.ErrorDescription?
    public let errorName: Definition.ErrorName?
    public let errorStep: Definition.ErrorStep?
    public let extent: Definition.Extent
    public let fullBackupSize: Int?
    public let incomingDeleteCount: Int?
    public let incomingUpdateCount: Int?
    public let itemGroupId: String?
    public let name = "sync"
    public let outgoingDeleteCount: Int?
    public let outgoingUpdateCount: Int?
    public let timestamp: Int
    public let treatProblem: Definition.TreatProblem?
    public let trigger: Definition.Trigger
  }
}
