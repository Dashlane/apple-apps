import Foundation

extension UserEvent {

  public struct `SetupRiskDetection`: Encodable, UserEventProtocol {
    public static let isPriority = false
    public init(`riskDetectionSetupStep`: Definition.RiskDetectionSetupStep) {
      self.riskDetectionSetupStep = riskDetectionSetupStep
    }
    public let name = "setup_risk_detection"
    public let riskDetectionSetupStep: Definition.RiskDetectionSetupStep
  }
}
