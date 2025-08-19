import Foundation

extension Definition {

  public struct `Web`: Encodable, Sendable {
    public init(
      `everflowTransactionId`: String? = nil, `gclid`: String? = nil, `hasCookie`: Bool,
      `heapIdentity`: String? = nil, `utmCampaign`: String? = nil, `utmContent`: String? = nil,
      `utmLastClickCampaign`: String? = nil, `utmLastClickContent`: String? = nil,
      `utmLastClickMedium`: String? = nil, `utmLastClickPathname`: String? = nil,
      `utmLastClickReferrer`: String? = nil, `utmLastClickSource`: String? = nil,
      `utmLastClickTerm`: String? = nil, `utmLastClickVisitTimestamp`: Int? = nil,
      `utmMedium`: String? = nil,
      `utmPathname`: String? = nil, `utmReferrer`: String? = nil, `utmSource`: String? = nil,
      `utmTerm`: String? = nil, `utmVisitTimestamp`: Int? = nil
    ) {
      self.everflowTransactionId = everflowTransactionId
      self.gclid = gclid
      self.hasCookie = hasCookie
      self.heapIdentity = heapIdentity
      self.utmCampaign = utmCampaign
      self.utmContent = utmContent
      self.utmLastClickCampaign = utmLastClickCampaign
      self.utmLastClickContent = utmLastClickContent
      self.utmLastClickMedium = utmLastClickMedium
      self.utmLastClickPathname = utmLastClickPathname
      self.utmLastClickReferrer = utmLastClickReferrer
      self.utmLastClickSource = utmLastClickSource
      self.utmLastClickTerm = utmLastClickTerm
      self.utmLastClickVisitTimestamp = utmLastClickVisitTimestamp
      self.utmMedium = utmMedium
      self.utmPathname = utmPathname
      self.utmReferrer = utmReferrer
      self.utmSource = utmSource
      self.utmTerm = utmTerm
      self.utmVisitTimestamp = utmVisitTimestamp
    }
    public let everflowTransactionId: String?
    public let gclid: String?
    public let hasCookie: Bool
    public let heapIdentity: String?
    public let utmCampaign: String?
    public let utmContent: String?
    public let utmLastClickCampaign: String?
    public let utmLastClickContent: String?
    public let utmLastClickMedium: String?
    public let utmLastClickPathname: String?
    public let utmLastClickReferrer: String?
    public let utmLastClickSource: String?
    public let utmLastClickTerm: String?
    public let utmLastClickVisitTimestamp: Int?
    public let utmMedium: String?
    public let utmPathname: String?
    public let utmReferrer: String?
    public let utmSource: String?
    public let utmTerm: String?
    public let utmVisitTimestamp: Int?
  }
}
