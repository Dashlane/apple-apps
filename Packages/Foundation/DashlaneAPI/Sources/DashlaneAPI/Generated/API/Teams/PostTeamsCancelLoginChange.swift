import Foundation

extension UserDeviceAPIClient.Teams {
  public struct CancelLoginChange: APIRequest, Sendable {
    public static let endpoint: Endpoint = "/teams/CancelLoginChange"

    public let api: UserDeviceAPIClient

    @discardableResult public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil)
      async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    @discardableResult public func callAsFunction(logins: [String], timeout: TimeInterval? = nil)
      async throws -> Response
    {
      let body = Body(logins: logins)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var cancelLoginChange: CancelLoginChange {
    CancelLoginChange(api: api)
  }
}

extension UserDeviceAPIClient.Teams.CancelLoginChange {
  public struct Body: Codable, Hashable, Sendable {
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

extension UserDeviceAPIClient.Teams.CancelLoginChange {
  public typealias Response = Empty?
}
