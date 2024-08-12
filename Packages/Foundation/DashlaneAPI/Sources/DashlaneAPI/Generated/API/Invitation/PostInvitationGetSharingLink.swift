import Foundation

extension AppAPIClient.Invitation {
  public struct GetSharingLink: APIRequest {
    public static let endpoint: Endpoint = "/invitation/GetSharingLink"

    public let api: AppAPIClient

    public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    public func callAsFunction(userKey: String, timeout: TimeInterval? = nil) async throws
      -> Response
    {
      let body = Body(userKey: userKey)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var getSharingLink: GetSharingLink {
    GetSharingLink(api: api)
  }
}

extension AppAPIClient.Invitation.GetSharingLink {
  public struct Body: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case userKey = "userKey"
    }

    public let userKey: String

    public init(userKey: String) {
      self.userKey = userKey
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(userKey, forKey: .userKey)
    }
  }
}

extension AppAPIClient.Invitation.GetSharingLink {
  public struct Response: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case sharingId = "sharingId"
    }

    public let sharingId: String

    public init(sharingId: String) {
      self.sharingId = sharingId
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(sharingId, forKey: .sharingId)
    }
  }
}
