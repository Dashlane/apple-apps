import Foundation

extension UserDeviceAPIClient.Teams {
  public struct RequestLoginChange: APIRequest, Sendable {
    public static let endpoint: Endpoint = "/teams/RequestLoginChange"

    public let api: UserDeviceAPIClient

    @discardableResult public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil)
      async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    @discardableResult public func callAsFunction(
      users: [Body.UsersElement], timeout: TimeInterval? = nil
    ) async throws -> Response {
      let body = Body(users: users)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var requestLoginChange: RequestLoginChange {
    RequestLoginChange(api: api)
  }
}

extension UserDeviceAPIClient.Teams.RequestLoginChange {
  public struct Body: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case users = "users"
    }

    public struct UsersElement: Codable, Hashable, Sendable {
      public enum CodingKeys: String, CodingKey {
        case currentLogin = "currentLogin"
        case newLogin = "newLogin"
      }

      public let currentLogin: String
      public let newLogin: String

      public init(currentLogin: String, newLogin: String) {
        self.currentLogin = currentLogin
        self.newLogin = newLogin
      }

      public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(currentLogin, forKey: .currentLogin)
        try container.encode(newLogin, forKey: .newLogin)
      }
    }

    public let users: [UsersElement]

    public init(users: [UsersElement]) {
      self.users = users
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(users, forKey: .users)
    }
  }
}

extension UserDeviceAPIClient.Teams.RequestLoginChange {
  public typealias Response = Empty?
}
