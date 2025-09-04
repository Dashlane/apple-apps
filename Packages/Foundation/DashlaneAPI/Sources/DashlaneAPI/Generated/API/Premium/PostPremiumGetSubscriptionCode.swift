import Foundation

extension UserDeviceAPIClient.Premium {
  public struct GetSubscriptionCode: APIRequest, Sendable {
    public static let endpoint: Endpoint = "/premium/GetSubscriptionCode"

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
  public var getSubscriptionCode: GetSubscriptionCode {
    GetSubscriptionCode(api: api)
  }
}

extension UserDeviceAPIClient.Premium.GetSubscriptionCode {
  public typealias Body = Empty?
}

extension UserDeviceAPIClient.Premium.GetSubscriptionCode {
  public struct Response: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case subscriptionCode = "subscriptionCode"
    }

    public let subscriptionCode: String

    public init(subscriptionCode: String) {
      self.subscriptionCode = subscriptionCode
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(subscriptionCode, forKey: .subscriptionCode)
    }
  }
}
