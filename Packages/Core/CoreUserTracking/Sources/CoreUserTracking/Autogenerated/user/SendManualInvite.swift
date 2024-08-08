import Foundation

extension UserEvent {

  public struct `SendManualInvite`: Encodable, UserEventProtocol {
    public static let isPriority = false
    public init(
      `flowStep`: Definition.FlowStep, `importSize`: Int? = nil, `initialSeatCount`: Int? = nil,
      `inviteCount`: Int, `inviteFailedCount`: Int, `inviteResentCount`: Int,
      `inviteSuccessfulCount`: Int, `isImport`: Bool, `isResend`: Bool, `seatAddedCount`: Int? = nil
    ) {
      self.flowStep = flowStep
      self.importSize = importSize
      self.initialSeatCount = initialSeatCount
      self.inviteCount = inviteCount
      self.inviteFailedCount = inviteFailedCount
      self.inviteResentCount = inviteResentCount
      self.inviteSuccessfulCount = inviteSuccessfulCount
      self.isImport = isImport
      self.isResend = isResend
      self.seatAddedCount = seatAddedCount
    }
    public let flowStep: Definition.FlowStep
    public let importSize: Int?
    public let initialSeatCount: Int?
    public let inviteCount: Int
    public let inviteFailedCount: Int
    public let inviteResentCount: Int
    public let inviteSuccessfulCount: Int
    public let isImport: Bool
    public let isResend: Bool
    public let name = "send_manual_invite"
    public let seatAddedCount: Int?
  }
}
