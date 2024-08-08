import Foundation

extension UserDeviceAPIClient.SharingUserdevice {
  public struct GetUsersPublicKey: APIRequest {
    public static let endpoint: Endpoint = "/sharing-userdevice/GetUsersPublicKey"

    public let api: UserDeviceAPIClient

    public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    public func callAsFunction(logins: [String], timeout: TimeInterval? = nil) async throws
      -> Response
    {
      let body = Body(logins: logins)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var getUsersPublicKey: GetUsersPublicKey {
    GetUsersPublicKey(api: api)
  }
}

extension UserDeviceAPIClient.SharingUserdevice.GetUsersPublicKey {
  public struct Body: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case logins = "logins"
    }

    public let logins: [String]

    public init(logins: [String]) {
      self.logins = logins
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(logins, forKey: .logins)
    }
  }
}

extension UserDeviceAPIClient.SharingUserdevice.GetUsersPublicKey {
  public struct Response: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case data = "data"
    }

    public struct DataValueElement: Codable, Equatable, Sendable {
      public enum CodingKeys: String, CodingKey {
        case email = "email"
        case login = "login"
        case publicKey = "publicKey"
      }

      public let email: String
      public let login: String?
      public let publicKey: String?

      public init(email: String, login: String?, publicKey: String?) {
        self.email = email
        self.login = login
        self.publicKey = publicKey
      }

      public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(email, forKey: .email)
        try container.encode(login, forKey: .login)
        try container.encode(publicKey, forKey: .publicKey)
      }
    }

    public let data: [DataValueElement]

    public init(data: [DataValueElement]) {
      self.data = data
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(data, forKey: .data)
    }
  }
}
