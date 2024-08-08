import Foundation

extension UserDeviceAPIClient.SharingUserdevice {
  public struct GetTeamLogins: APIRequest {
    public static let endpoint: Endpoint = "/sharing-userdevice/GetTeamLogins"

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
  public var getTeamLogins: GetTeamLogins {
    GetTeamLogins(api: api)
  }
}

extension UserDeviceAPIClient.SharingUserdevice.GetTeamLogins {
  public typealias Body = Empty?
}

extension UserDeviceAPIClient.SharingUserdevice.GetTeamLogins {
  public struct Response: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case teamLogins = "teamLogins"
      case usersMetadata = "usersMetadata"
    }

    public struct UsersMetadataElement: Codable, Equatable, Sendable {
      public enum CodingKeys: String, CodingKey {
        case login = "login"
        case familyName = "familyName"
        case formattedName = "formattedName"
        case givenName = "givenName"
      }

      public let login: String
      public let familyName: String?
      public let formattedName: String?
      public let givenName: String?

      public init(
        login: String, familyName: String? = nil, formattedName: String? = nil,
        givenName: String? = nil
      ) {
        self.login = login
        self.familyName = familyName
        self.formattedName = formattedName
        self.givenName = givenName
      }

      public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(login, forKey: .login)
        try container.encodeIfPresent(familyName, forKey: .familyName)
        try container.encodeIfPresent(formattedName, forKey: .formattedName)
        try container.encodeIfPresent(givenName, forKey: .givenName)
      }
    }

    public let teamLogins: [String]
    public let usersMetadata: [UsersMetadataElement]?

    public init(teamLogins: [String], usersMetadata: [UsersMetadataElement]? = nil) {
      self.teamLogins = teamLogins
      self.usersMetadata = usersMetadata
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(teamLogins, forKey: .teamLogins)
      try container.encodeIfPresent(usersMetadata, forKey: .usersMetadata)
    }
  }
}
