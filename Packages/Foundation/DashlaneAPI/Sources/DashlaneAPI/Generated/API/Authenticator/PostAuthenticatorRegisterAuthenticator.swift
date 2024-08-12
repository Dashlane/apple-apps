import Foundation

extension UserDeviceAPIClient.Authenticator {
  public struct RegisterAuthenticator: APIRequest {
    public static let endpoint: Endpoint = "/authenticator/RegisterAuthenticator"

    public let api: UserDeviceAPIClient

    @discardableResult public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil)
      async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    @discardableResult public func callAsFunction(
      push: Body.Push? = nil, timeout: TimeInterval? = nil
    ) async throws -> Response {
      let body = Body(push: push)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var registerAuthenticator: RegisterAuthenticator {
    RegisterAuthenticator(api: api)
  }
}

extension UserDeviceAPIClient.Authenticator.RegisterAuthenticator {
  public struct Body: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case push = "push"
    }

    public struct Push: Codable, Equatable, Sendable {
      public enum CodingKeys: String, CodingKey {
        case pushId = "pushId"
        case platform = "platform"
      }

      public enum Platform: String, Sendable, Equatable, CaseIterable, Codable {
        case apn = "apn"
        case gcm = "gcm"
        case undecodable
        public init(from decoder: Decoder) throws {
          let container = try decoder.singleValueContainer()
          let rawValue = try container.decode(String.self)
          self = Self(rawValue: rawValue) ?? .undecodable
        }
      }

      public let pushId: String
      public let platform: Platform

      public init(pushId: String, platform: Platform) {
        self.pushId = pushId
        self.platform = platform
      }

      public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(pushId, forKey: .pushId)
        try container.encode(platform, forKey: .platform)
      }
    }

    public let push: Push?

    public init(push: Push? = nil) {
      self.push = push
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encodeIfPresent(push, forKey: .push)
    }
  }
}

extension UserDeviceAPIClient.Authenticator.RegisterAuthenticator {
  public typealias Response = Empty?
}
