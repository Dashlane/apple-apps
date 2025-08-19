import Foundation

extension UserDeviceAPIClient.Payments {
  public struct GetAccessibleStoreOffers: APIRequest, Sendable {
    public static let endpoint: Endpoint = "/payments/GetAccessibleStoreOffers"

    public let api: UserDeviceAPIClient

    public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    public func callAsFunction(platform: Body.Platform, timeout: TimeInterval? = nil) async throws
      -> Response
    {
      let body = Body(platform: platform)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var getAccessibleStoreOffers: GetAccessibleStoreOffers {
    GetAccessibleStoreOffers(api: api)
  }
}

extension UserDeviceAPIClient.Payments.GetAccessibleStoreOffers {
  public struct Body: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case platform = "platform"
    }

    public enum Platform: String, Sendable, Hashable, Codable, CaseIterable {
      case playstore = "playstore"
      case ios = "ios"
      case playstoreSubscription = "playstore_subscription"
      case macappstore = "macappstore"
      case desktop = "desktop"
      case realWebsite = "real_website"
      case undecodable
      public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = Self(rawValue: rawValue) ?? .undecodable
      }
    }

    public let platform: Platform

    public init(platform: Platform) {
      self.platform = platform
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(platform, forKey: .platform)
    }
  }
}

extension UserDeviceAPIClient.Payments.GetAccessibleStoreOffers {
  public struct Response: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case freeOffers = "freeOffers"
      case essentialsOffers = "essentialsOffers"
      case premiumOffers = "premiumOffers"
      case familyOffers = "familyOffers"
      case currentSubscription = "currentSubscription"
      case currentSubscriptionType = "currentSubscriptionType"
      case purchaseToken = "purchaseToken"
    }

    public enum CurrentSubscriptionType: String, Sendable, Hashable, Codable, CaseIterable {
      case amazon = "amazon"
      case freeTrial = "free_trial"
      case invoice = "invoice"
      case ios = "ios"
      case iosRenewable = "ios_renewable"
      case mac = "mac"
      case macRenewable = "mac_renewable"
      case offer = "offer"
      case partner = "partner"
      case paypal = "paypal"
      case paypalRenewable = "paypal_renewable"
      case playstore = "playstore"
      case playstoreRenewable = "playstore_renewable"
      case stripe = "stripe"
      case undecodable
      public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = Self(rawValue: rawValue) ?? .undecodable
      }
    }

    public let freeOffers: PaymentsAccessibleStoreOffers2
    public let essentialsOffers: PaymentsAccessibleStoreOffers2
    public let premiumOffers: PaymentsAccessibleStoreOffers2
    public let familyOffers: PaymentsAccessibleStoreOffers2
    public let currentSubscription: String?
    public let currentSubscriptionType: CurrentSubscriptionType?
    public let purchaseToken: String?

    public init(
      freeOffers: PaymentsAccessibleStoreOffers2, essentialsOffers: PaymentsAccessibleStoreOffers2,
      premiumOffers: PaymentsAccessibleStoreOffers2, familyOffers: PaymentsAccessibleStoreOffers2,
      currentSubscription: String? = nil, currentSubscriptionType: CurrentSubscriptionType? = nil,
      purchaseToken: String? = nil
    ) {
      self.freeOffers = freeOffers
      self.essentialsOffers = essentialsOffers
      self.premiumOffers = premiumOffers
      self.familyOffers = familyOffers
      self.currentSubscription = currentSubscription
      self.currentSubscriptionType = currentSubscriptionType
      self.purchaseToken = purchaseToken
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(freeOffers, forKey: .freeOffers)
      try container.encode(essentialsOffers, forKey: .essentialsOffers)
      try container.encode(premiumOffers, forKey: .premiumOffers)
      try container.encode(familyOffers, forKey: .familyOffers)
      try container.encodeIfPresent(currentSubscription, forKey: .currentSubscription)
      try container.encodeIfPresent(currentSubscriptionType, forKey: .currentSubscriptionType)
      try container.encodeIfPresent(purchaseToken, forKey: .purchaseToken)
    }
  }
}
