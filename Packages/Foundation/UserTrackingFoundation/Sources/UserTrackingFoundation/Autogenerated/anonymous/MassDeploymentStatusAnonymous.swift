import Foundation

extension AnonymousEvent {

  public struct `MassDeploymentStatus`: Encodable, AnonymousEventProtocol {
    public static let isPriority = false
    public init(
      `isProtectedByCredentialRiskDetection`: Bool, `massDeploymentAccessKey`: String,
      `massDeploymentDeviceId`: LowercasedUUID
    ) {
      self.isProtectedByCredentialRiskDetection = isProtectedByCredentialRiskDetection
      self.massDeploymentAccessKey = massDeploymentAccessKey
      self.massDeploymentDeviceId = massDeploymentDeviceId
    }
    public let isProtectedByCredentialRiskDetection: Bool
    public let massDeploymentAccessKey: String
    public let massDeploymentDeviceId: LowercasedUUID
    public let name = "mass_deployment_status"
  }
}
