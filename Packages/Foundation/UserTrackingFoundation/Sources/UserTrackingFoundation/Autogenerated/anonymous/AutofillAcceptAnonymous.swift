import Foundation

extension AnonymousEvent {

  public struct `AutofillAccept`: Encodable, AnonymousEventProtocol {
    public static let isPriority = true
    public init(
      `domain`: Definition.Domain, `isProtected`: Bool? = nil, `isSetAsDefault`: Bool? = nil,
      `itemPosition`: Int? = nil, `phishingRisk`: Definition.PhishingRisk? = nil,
      `webcardOptionSelected`: Definition.WebcardSaveOptions? = nil
    ) {
      self.domain = domain
      self.isProtected = isProtected
      self.isSetAsDefault = isSetAsDefault
      self.itemPosition = itemPosition
      self.phishingRisk = phishingRisk
      self.webcardOptionSelected = webcardOptionSelected
    }
    public let domain: Definition.Domain
    public let isProtected: Bool?
    public let isSetAsDefault: Bool?
    public let itemPosition: Int?
    public let name = "autofill_accept"
    public let phishingRisk: Definition.PhishingRisk?
    public let webcardOptionSelected: Definition.WebcardSaveOptions?
  }
}
