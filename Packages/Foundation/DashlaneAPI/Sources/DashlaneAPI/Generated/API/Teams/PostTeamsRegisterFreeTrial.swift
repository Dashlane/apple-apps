import Foundation

extension AppAPIClient.Teams {
  public struct RegisterFreeTrial: APIRequest {
    public static let endpoint: Endpoint = "/teams/RegisterFreeTrial"

    public let api: AppAPIClient

    @discardableResult public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil)
      async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    @discardableResult public func callAsFunction(
      creatorEmail: String, language: String, companyName: String? = nil,
      companySize: String? = nil, consents: [Body.ConsentsElement]? = nil,
      cookieJson: String? = nil, creatorPhoneNumber: String? = nil, firstName: String? = nil,
      gclid: String? = nil, lastName: String? = nil, lastClickCampaign: String? = nil,
      lastClickContent: String? = nil, lastClickMedium: String? = nil,
      lastClickSource: String? = nil, lastClickTerm: String? = nil, mCookie: String? = nil,
      originHostname: String? = nil, originPathname: String? = nil, tier: Body.Tier? = nil,
      utmCampaign: String? = nil, utmContent: String? = nil, utmMedium: String? = nil,
      utmSource: String? = nil, utmTerm: String? = nil, timeout: TimeInterval? = nil
    ) async throws -> Response {
      let body = Body(
        creatorEmail: creatorEmail, language: language, companyName: companyName,
        companySize: companySize, consents: consents, cookieJson: cookieJson,
        creatorPhoneNumber: creatorPhoneNumber, firstName: firstName, gclid: gclid,
        lastName: lastName, lastClickCampaign: lastClickCampaign,
        lastClickContent: lastClickContent, lastClickMedium: lastClickMedium,
        lastClickSource: lastClickSource, lastClickTerm: lastClickTerm, mCookie: mCookie,
        originHostname: originHostname, originPathname: originPathname, tier: tier,
        utmCampaign: utmCampaign, utmContent: utmContent, utmMedium: utmMedium,
        utmSource: utmSource, utmTerm: utmTerm)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var registerFreeTrial: RegisterFreeTrial {
    RegisterFreeTrial(api: api)
  }
}

extension AppAPIClient.Teams.RegisterFreeTrial {
  public struct Body: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case creatorEmail = "creatorEmail"
      case language = "language"
      case companyName = "companyName"
      case companySize = "companySize"
      case consents = "consents"
      case cookieJson = "cookieJson"
      case creatorPhoneNumber = "creatorPhoneNumber"
      case firstName = "firstName"
      case gclid = "gclid"
      case lastName = "lastName"
      case lastClickCampaign = "last_click_campaign"
      case lastClickContent = "last_click_content"
      case lastClickMedium = "last_click_medium"
      case lastClickSource = "last_click_source"
      case lastClickTerm = "last_click_term"
      case mCookie = "mCookie"
      case originHostname = "originHostname"
      case originPathname = "originPathname"
      case tier = "tier"
      case utmCampaign = "utm_campaign"
      case utmContent = "utm_content"
      case utmMedium = "utm_medium"
      case utmSource = "utm_source"
      case utmTerm = "utm_term"
    }

    public struct ConsentsElement: Codable, Equatable, Sendable {
      public enum CodingKeys: String, CodingKey {
        case consentType = "consentType"
        case status = "status"
      }

      public enum ConsentType: String, Sendable, Equatable, CaseIterable, Codable {
        case privacyPolicyAndToS = "privacyPolicyAndToS"
        case emailsOffersAndTips = "emailsOffersAndTips"
        case undecodable
        public init(from decoder: Decoder) throws {
          let container = try decoder.singleValueContainer()
          let rawValue = try container.decode(String.self)
          self = Self(rawValue: rawValue) ?? .undecodable
        }
      }

      public let consentType: ConsentType
      public let status: Bool

      public init(consentType: ConsentType, status: Bool) {
        self.consentType = consentType
        self.status = status
      }

      public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(consentType, forKey: .consentType)
        try container.encode(status, forKey: .status)
      }
    }

    public enum Tier: String, Sendable, Equatable, CaseIterable, Codable {
      case legacy = "legacy"
      case team = "team"
      case business = "business"
      case undecodable
      public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = Self(rawValue: rawValue) ?? .undecodable
      }
    }

    public let creatorEmail: String
    public let language: String
    public let companyName: String?
    public let companySize: String?
    public let consents: [ConsentsElement]?
    public let cookieJson: String?
    public let creatorPhoneNumber: String?
    public let firstName: String?
    public let gclid: String?
    public let lastName: String?
    public let lastClickCampaign: String?
    public let lastClickContent: String?
    public let lastClickMedium: String?
    public let lastClickSource: String?
    public let lastClickTerm: String?
    public let mCookie: String?
    public let originHostname: String?
    public let originPathname: String?
    public let tier: Tier?
    public let utmCampaign: String?
    public let utmContent: String?
    public let utmMedium: String?
    public let utmSource: String?
    public let utmTerm: String?

    public init(
      creatorEmail: String, language: String, companyName: String? = nil,
      companySize: String? = nil, consents: [ConsentsElement]? = nil, cookieJson: String? = nil,
      creatorPhoneNumber: String? = nil, firstName: String? = nil, gclid: String? = nil,
      lastName: String? = nil, lastClickCampaign: String? = nil, lastClickContent: String? = nil,
      lastClickMedium: String? = nil, lastClickSource: String? = nil, lastClickTerm: String? = nil,
      mCookie: String? = nil, originHostname: String? = nil, originPathname: String? = nil,
      tier: Tier? = nil, utmCampaign: String? = nil, utmContent: String? = nil,
      utmMedium: String? = nil, utmSource: String? = nil, utmTerm: String? = nil
    ) {
      self.creatorEmail = creatorEmail
      self.language = language
      self.companyName = companyName
      self.companySize = companySize
      self.consents = consents
      self.cookieJson = cookieJson
      self.creatorPhoneNumber = creatorPhoneNumber
      self.firstName = firstName
      self.gclid = gclid
      self.lastName = lastName
      self.lastClickCampaign = lastClickCampaign
      self.lastClickContent = lastClickContent
      self.lastClickMedium = lastClickMedium
      self.lastClickSource = lastClickSource
      self.lastClickTerm = lastClickTerm
      self.mCookie = mCookie
      self.originHostname = originHostname
      self.originPathname = originPathname
      self.tier = tier
      self.utmCampaign = utmCampaign
      self.utmContent = utmContent
      self.utmMedium = utmMedium
      self.utmSource = utmSource
      self.utmTerm = utmTerm
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(creatorEmail, forKey: .creatorEmail)
      try container.encode(language, forKey: .language)
      try container.encodeIfPresent(companyName, forKey: .companyName)
      try container.encodeIfPresent(companySize, forKey: .companySize)
      try container.encodeIfPresent(consents, forKey: .consents)
      try container.encodeIfPresent(cookieJson, forKey: .cookieJson)
      try container.encodeIfPresent(creatorPhoneNumber, forKey: .creatorPhoneNumber)
      try container.encodeIfPresent(firstName, forKey: .firstName)
      try container.encodeIfPresent(gclid, forKey: .gclid)
      try container.encodeIfPresent(lastName, forKey: .lastName)
      try container.encodeIfPresent(lastClickCampaign, forKey: .lastClickCampaign)
      try container.encodeIfPresent(lastClickContent, forKey: .lastClickContent)
      try container.encodeIfPresent(lastClickMedium, forKey: .lastClickMedium)
      try container.encodeIfPresent(lastClickSource, forKey: .lastClickSource)
      try container.encodeIfPresent(lastClickTerm, forKey: .lastClickTerm)
      try container.encodeIfPresent(mCookie, forKey: .mCookie)
      try container.encodeIfPresent(originHostname, forKey: .originHostname)
      try container.encodeIfPresent(originPathname, forKey: .originPathname)
      try container.encodeIfPresent(tier, forKey: .tier)
      try container.encodeIfPresent(utmCampaign, forKey: .utmCampaign)
      try container.encodeIfPresent(utmContent, forKey: .utmContent)
      try container.encodeIfPresent(utmMedium, forKey: .utmMedium)
      try container.encodeIfPresent(utmSource, forKey: .utmSource)
      try container.encodeIfPresent(utmTerm, forKey: .utmTerm)
    }
  }
}

extension AppAPIClient.Teams.RegisterFreeTrial {
  public typealias Response = Empty?
}
