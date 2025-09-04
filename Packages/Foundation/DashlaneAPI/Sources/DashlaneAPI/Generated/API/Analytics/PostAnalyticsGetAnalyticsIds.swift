import Foundation

extension AppAPIClient.Analytics {
  public struct GetAnalyticsIds: APIRequest, Sendable {
    public static let endpoint: Endpoint = "/analytics/GetAnalyticsIds"

    public let api: AppAPIClient

    public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    public func callAsFunction(login: String, timeout: TimeInterval? = nil) async throws -> Response
    {
      let body = Body(login: login)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var getAnalyticsIds: GetAnalyticsIds {
    GetAnalyticsIds(api: api)
  }
}

extension AppAPIClient.Analytics.GetAnalyticsIds {
  public struct Body: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case login = "login"
    }

    public let login: String

    public init(login: String) {
      self.login = login
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(login, forKey: .login)
    }
  }
}

extension AppAPIClient.Analytics.GetAnalyticsIds {
  public struct Response: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case devicesAnalyticsIds = "devicesAnalyticsIds"
      case userAnalyticsId = "userAnalyticsId"
    }

    public let devicesAnalyticsIds: [String]?
    public let userAnalyticsId: String?

    public init(devicesAnalyticsIds: [String]? = nil, userAnalyticsId: String? = nil) {
      self.devicesAnalyticsIds = devicesAnalyticsIds
      self.userAnalyticsId = userAnalyticsId
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encodeIfPresent(devicesAnalyticsIds, forKey: .devicesAnalyticsIds)
      try container.encodeIfPresent(userAnalyticsId, forKey: .userAnalyticsId)
    }
  }
}
