import Foundation

extension AnonymousEvent {

  public struct `AntiphishingDisplayAlert`: Encodable, AnonymousEventProtocol {
    public static let isPriority = false
    public init(
      `domain`: Definition.Domain, `msToAlert`: Int, `msToPrediction`: Int? = nil,
      `msToScraping`: Int? = nil
    ) {
      self.domain = domain
      self.msToAlert = msToAlert
      self.msToPrediction = msToPrediction
      self.msToScraping = msToScraping
    }
    public let domain: Definition.Domain
    public let msToAlert: Int
    public let msToPrediction: Int?
    public let msToScraping: Int?
    public let name = "antiphishing_display_alert"
  }
}
