import Foundation

extension UserDeviceAPIClient.User {
  public struct RequestLoginChange: APIRequest, Sendable {
    public static let endpoint: Endpoint = "/user/RequestLoginChange"

    public let api: UserDeviceAPIClient

    @discardableResult public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil)
      async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    @discardableResult public func callAsFunction(newLogin: String, timeout: TimeInterval? = nil)
      async throws -> Response
    {
      let body = Body(newLogin: newLogin)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var requestLoginChange: RequestLoginChange {
    RequestLoginChange(api: api)
  }
}

extension UserDeviceAPIClient.User.RequestLoginChange {
  public struct Body: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case newLogin = "newLogin"
    }

    public let newLogin: String

    public init(newLogin: String) {
      self.newLogin = newLogin
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(newLogin, forKey: .newLogin)
    }
  }
}

extension UserDeviceAPIClient.User.RequestLoginChange {
  public typealias Response = Empty?
}
