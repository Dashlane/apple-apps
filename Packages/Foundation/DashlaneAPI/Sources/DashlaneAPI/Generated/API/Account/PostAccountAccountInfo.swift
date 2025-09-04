import Foundation

extension UserDeviceAPIClient.Account {
  public struct AccountInfo: APIRequest, Sendable {
    public static let endpoint: Endpoint = "/account/AccountInfo"

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
  public var accountInfo: AccountInfo {
    AccountInfo(api: api)
  }
}

extension UserDeviceAPIClient.Account.AccountInfo {
  public typealias Body = Empty?
}

extension UserDeviceAPIClient.Account.AccountInfo {
  public struct Response: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case creationDateUnix = "creationDateUnix"
      case publicUserId = "publicUserId"
      case contactEmail = "contactEmail"
      case contactPhone = "contactPhone"
      case deviceAnalyticsId = "deviceAnalyticsId"
      case userAnalyticsId = "userAnalyticsId"
    }

    public let creationDateUnix: Int
    public let publicUserId: String
    public let contactEmail: String?
    public let contactPhone: String?
    public let deviceAnalyticsId: String?
    public let userAnalyticsId: String?

    public init(
      creationDateUnix: Int, publicUserId: String, contactEmail: String? = nil,
      contactPhone: String? = nil, deviceAnalyticsId: String? = nil, userAnalyticsId: String? = nil
    ) {
      self.creationDateUnix = creationDateUnix
      self.publicUserId = publicUserId
      self.contactEmail = contactEmail
      self.contactPhone = contactPhone
      self.deviceAnalyticsId = deviceAnalyticsId
      self.userAnalyticsId = userAnalyticsId
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(creationDateUnix, forKey: .creationDateUnix)
      try container.encode(publicUserId, forKey: .publicUserId)
      try container.encodeIfPresent(contactEmail, forKey: .contactEmail)
      try container.encodeIfPresent(contactPhone, forKey: .contactPhone)
      try container.encodeIfPresent(deviceAnalyticsId, forKey: .deviceAnalyticsId)
      try container.encodeIfPresent(userAnalyticsId, forKey: .userAnalyticsId)
    }
  }
}
