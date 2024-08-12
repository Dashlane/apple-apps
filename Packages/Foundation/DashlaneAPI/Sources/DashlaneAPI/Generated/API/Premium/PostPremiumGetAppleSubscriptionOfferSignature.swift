import Foundation

extension UserDeviceAPIClient.Premium {
  public struct GetAppleSubscriptionOfferSignature: APIRequest {
    public static let endpoint: Endpoint = "/premium/GetAppleSubscriptionOfferSignature"

    public let api: UserDeviceAPIClient

    public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    public func callAsFunction(
      appBundleID: Body.AppBundleID, productIdentifier: String, offerIdentifier: String,
      applicationUsername: String, timeout: TimeInterval? = nil
    ) async throws -> Response {
      let body = Body(
        appBundleID: appBundleID, productIdentifier: productIdentifier,
        offerIdentifier: offerIdentifier, applicationUsername: applicationUsername)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var getAppleSubscriptionOfferSignature: GetAppleSubscriptionOfferSignature {
    GetAppleSubscriptionOfferSignature(api: api)
  }
}

extension UserDeviceAPIClient.Premium.GetAppleSubscriptionOfferSignature {
  public struct Body: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case appBundleID = "appBundleID"
      case productIdentifier = "productIdentifier"
      case offerIdentifier = "offerIdentifier"
      case applicationUsername = "applicationUsername"
    }

    public enum AppBundleID: String, Sendable, Equatable, CaseIterable, Codable {
      case comDashlaneDashlanephonefinaldev = "com.dashlane.dashlanephonefinaldev"
      case comDashlaneDashlanephonefinal = "com.dashlane.dashlanephonefinal"
      case comDashlaneDashlane = "com.dashlane.Dashlane"
      case undecodable
      public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = Self(rawValue: rawValue) ?? .undecodable
      }
    }

    public let appBundleID: AppBundleID
    public let productIdentifier: String
    public let offerIdentifier: String
    public let applicationUsername: String

    public init(
      appBundleID: AppBundleID, productIdentifier: String, offerIdentifier: String,
      applicationUsername: String
    ) {
      self.appBundleID = appBundleID
      self.productIdentifier = productIdentifier
      self.offerIdentifier = offerIdentifier
      self.applicationUsername = applicationUsername
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(appBundleID, forKey: .appBundleID)
      try container.encode(productIdentifier, forKey: .productIdentifier)
      try container.encode(offerIdentifier, forKey: .offerIdentifier)
      try container.encode(applicationUsername, forKey: .applicationUsername)
    }
  }
}

extension UserDeviceAPIClient.Premium.GetAppleSubscriptionOfferSignature {
  public struct Response: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case keyIdentifier = "keyIdentifier"
      case nonce = "nonce"
      case signature = "signature"
      case timestamp = "timestamp"
    }

    public let keyIdentifier: String
    public let nonce: String
    public let signature: String
    public let timestamp: String

    public init(keyIdentifier: String, nonce: String, signature: String, timestamp: String) {
      self.keyIdentifier = keyIdentifier
      self.nonce = nonce
      self.signature = signature
      self.timestamp = timestamp
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(keyIdentifier, forKey: .keyIdentifier)
      try container.encode(nonce, forKey: .nonce)
      try container.encode(signature, forKey: .signature)
      try container.encode(timestamp, forKey: .timestamp)
    }
  }
}
