import Foundation

extension UserDeviceAPIClient.Premium {
  public struct GetSubscriptionInfo: APIRequest {
    public static let endpoint: Endpoint = "/premium/GetSubscriptionInfo"

    public let api: UserDeviceAPIClient

    public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    public func callAsFunction(timeout: TimeInterval? = nil) async throws -> Response {
      let body = Body()
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var getSubscriptionInfo: GetSubscriptionInfo {
    GetSubscriptionInfo(api: api)
  }
}

extension UserDeviceAPIClient.Premium.GetSubscriptionInfo {
  public typealias Body = Empty?
}

extension UserDeviceAPIClient.Premium.GetSubscriptionInfo {
  public struct Response: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case b2cSubscription = "b2cSubscription"
      case b2bSubscription = "b2bSubscription"
    }

    public struct B2cSubscription: Codable, Equatable, Sendable {
      public enum CodingKeys: String, CodingKey {
        case autoRenewInfo = "autoRenewInfo"
        case hasInvoices = "hasInvoices"
        case billingInformation = "billingInformation"
      }

      public struct AutoRenewInfo: Codable, Equatable, Sendable {
        public enum CodingKeys: String, CodingKey {
          case theory = "theory"
          case reality = "reality"
          case periodicity = "periodicity"
          case trigger = "trigger"
        }

        public enum Periodicity: String, Sendable, Equatable, CaseIterable, Codable {
          case yearly = "yearly"
          case monthly = "monthly"
          case other = "other"
          case undecodable
          public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let rawValue = try container.decode(String.self)
            self = Self(rawValue: rawValue) ?? .undecodable
          }
        }

        public enum Trigger: String, Sendable, Equatable, CaseIterable, Codable {
          case manual = "manual"
          case automatic = "automatic"
          case undecodable
          public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let rawValue = try container.decode(String.self)
            self = Self(rawValue: rawValue) ?? .undecodable
          }
        }

        public let theory: Bool
        public let reality: Bool
        public let periodicity: Periodicity?
        public let trigger: Trigger?

        public init(
          theory: Bool, reality: Bool, periodicity: Periodicity? = nil, trigger: Trigger? = nil
        ) {
          self.theory = theory
          self.reality = reality
          self.periodicity = periodicity
          self.trigger = trigger
        }

        public func encode(to encoder: Encoder) throws {
          var container = encoder.container(keyedBy: CodingKeys.self)
          try container.encode(theory, forKey: .theory)
          try container.encode(reality, forKey: .reality)
          try container.encodeIfPresent(periodicity, forKey: .periodicity)
          try container.encodeIfPresent(trigger, forKey: .trigger)
        }
      }

      public let autoRenewInfo: AutoRenewInfo
      public let hasInvoices: Bool
      public let billingInformation: PremiumSubscriptionInfoBillingInformation?

      public init(
        autoRenewInfo: AutoRenewInfo, hasInvoices: Bool,
        billingInformation: PremiumSubscriptionInfoBillingInformation? = nil
      ) {
        self.autoRenewInfo = autoRenewInfo
        self.hasInvoices = hasInvoices
        self.billingInformation = billingInformation
      }

      public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(autoRenewInfo, forKey: .autoRenewInfo)
        try container.encode(hasInvoices, forKey: .hasInvoices)
        try container.encodeIfPresent(billingInformation, forKey: .billingInformation)
      }
    }

    public struct B2bSubscription: Codable, Equatable, Sendable {
      public enum CodingKeys: String, CodingKey {
        case hasInvoices = "hasInvoices"
        case billingInformation = "billingInformation"
        case vatNumber = "vatNumber"
      }

      public let hasInvoices: Bool
      public let billingInformation: PremiumSubscriptionInfoBillingInformation?
      public let vatNumber: String?

      public init(
        hasInvoices: Bool, billingInformation: PremiumSubscriptionInfoBillingInformation? = nil,
        vatNumber: String? = nil
      ) {
        self.hasInvoices = hasInvoices
        self.billingInformation = billingInformation
        self.vatNumber = vatNumber
      }

      public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(hasInvoices, forKey: .hasInvoices)
        try container.encodeIfPresent(billingInformation, forKey: .billingInformation)
        try container.encodeIfPresent(vatNumber, forKey: .vatNumber)
      }
    }

    public let b2cSubscription: B2cSubscription
    public let b2bSubscription: B2bSubscription?

    public init(b2cSubscription: B2cSubscription, b2bSubscription: B2bSubscription? = nil) {
      self.b2cSubscription = b2cSubscription
      self.b2bSubscription = b2bSubscription
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(b2cSubscription, forKey: .b2cSubscription)
      try container.encodeIfPresent(b2bSubscription, forKey: .b2bSubscription)
    }
  }
}
