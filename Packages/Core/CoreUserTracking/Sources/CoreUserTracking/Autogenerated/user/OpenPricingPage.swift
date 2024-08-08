import Foundation

extension UserEvent {

  public struct `OpenPricingPage`: Encodable, UserEventProtocol {
    public static let isPriority = false
    public init(`callToAction`: Definition.CallToAction) {
      self.callToAction = callToAction
    }
    public let callToAction: Definition.CallToAction
    public let name = "open_pricing_page"
  }
}
