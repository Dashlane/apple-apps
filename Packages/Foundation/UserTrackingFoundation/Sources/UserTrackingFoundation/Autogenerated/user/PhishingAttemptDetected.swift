import Foundation

extension UserEvent {

  public struct `PhishingAttemptDetected`: Encodable, UserEventProtocol {
    public static let isPriority = false
    public init(
      `confidenceInterval`: Int? = nil, `formType`: Definition.FormType,
      `modelVersion`: String? = nil
    ) {
      self.confidenceInterval = confidenceInterval
      self.formType = formType
      self.modelVersion = modelVersion
    }
    public let confidenceInterval: Int?
    public let formType: Definition.FormType
    public let modelVersion: String?
    public let name = "phishing_attempt_detected"
  }
}
