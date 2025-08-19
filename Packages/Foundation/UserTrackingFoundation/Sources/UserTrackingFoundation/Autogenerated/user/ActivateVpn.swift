import Foundation

extension UserEvent {

  public struct `ActivateVpn`: Encodable, UserEventProtocol {
    public static let isPriority = false
    public init(`errorName`: Definition.ActivateVpnError? = nil, `flowStep`: Definition.FlowStep) {
      self.errorName = errorName
      self.flowStep = flowStep
    }
    public let errorName: Definition.ActivateVpnError?
    public let flowStep: Definition.FlowStep
    public let name = "activate_vpn"
  }
}
