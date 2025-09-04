import Foundation

extension UserDeviceAPIClient.Payments {
  public struct VerifyApplestoreReceipt: APIRequest, Sendable {
    public static let endpoint: Endpoint = "/payments/VerifyApplestoreReceipt"

    public let api: UserDeviceAPIClient

    public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    public func callAsFunction(
      receipt: String, amount: String? = nil, billingCountry: String? = nil,
      context: Body.Context? = nil, currency: String? = nil, transactionIdentifier: String? = nil,
      timeout: TimeInterval? = nil
    ) async throws -> Response {
      let body = Body(
        receipt: receipt, amount: amount, billingCountry: billingCountry, context: context,
        currency: currency, transactionIdentifier: transactionIdentifier)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var verifyApplestoreReceipt: VerifyApplestoreReceipt {
    VerifyApplestoreReceipt(api: api)
  }
}

extension UserDeviceAPIClient.Payments.VerifyApplestoreReceipt {
  public struct Body: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case receipt = "receipt"
      case amount = "amount"
      case billingCountry = "billingCountry"
      case context = "context"
      case currency = "currency"
      case transactionIdentifier = "transactionIdentifier"
    }

    public enum Context: String, Sendable, Hashable, Codable, CaseIterable {
      case postLaunch = "postLaunch"
      case purchase = "purchase"
      case updates = "updates"
      case undecodable
      public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = Self(rawValue: rawValue) ?? .undecodable
      }
    }

    public let receipt: String
    public let amount: String?
    public let billingCountry: String?
    public let context: Context?
    public let currency: String?
    public let transactionIdentifier: String?

    public init(
      receipt: String, amount: String? = nil, billingCountry: String? = nil,
      context: Context? = nil, currency: String? = nil, transactionIdentifier: String? = nil
    ) {
      self.receipt = receipt
      self.amount = amount
      self.billingCountry = billingCountry
      self.context = context
      self.currency = currency
      self.transactionIdentifier = transactionIdentifier
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(receipt, forKey: .receipt)
      try container.encodeIfPresent(amount, forKey: .amount)
      try container.encodeIfPresent(billingCountry, forKey: .billingCountry)
      try container.encodeIfPresent(context, forKey: .context)
      try container.encodeIfPresent(currency, forKey: .currency)
      try container.encodeIfPresent(transactionIdentifier, forKey: .transactionIdentifier)
    }
  }
}

extension UserDeviceAPIClient.Payments.VerifyApplestoreReceipt {
  public struct Response: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case success = "success"
      case planType = "planType"
    }

    public let success: Bool
    public let planType: String?

    public init(success: Bool, planType: String? = nil) {
      self.success = success
      self.planType = planType
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(success, forKey: .success)
      try container.encodeIfPresent(planType, forKey: .planType)
    }
  }
}
