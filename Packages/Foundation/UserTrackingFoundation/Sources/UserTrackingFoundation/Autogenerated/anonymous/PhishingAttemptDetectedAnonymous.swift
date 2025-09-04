import Foundation

extension AnonymousEvent {

  public struct `PhishingAttemptDetected`: Encodable, AnonymousEventProtocol {
    public static let isPriority = false
    public init(
      `confidence`: Double, `domain`: Definition.Domain, `formType`: Definition.FormType,
      `modelVersion`: String? = nil
    ) {
      self.confidence = confidence
      self.domain = domain
      self.formType = formType
      self.modelVersion = modelVersion
    }
    public let confidence: Double
    public let domain: Definition.Domain
    public let formType: Definition.FormType
    public let modelVersion: String?
    public let name = "phishing_attempt_detected"
  }
}
