import Foundation

extension UserDeviceAPIClient.User {
  public struct CompleteLoginChange: APIRequest, Sendable {
    public static let endpoint: Endpoint = "/user/CompleteLoginChange"

    public let api: UserDeviceAPIClient

    @discardableResult public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil)
      async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    @discardableResult public func callAsFunction(
      validationToken: String, timeout: TimeInterval? = nil
    ) async throws -> Response {
      let body = Body(validationToken: validationToken)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var completeLoginChange: CompleteLoginChange {
    CompleteLoginChange(api: api)
  }
}

extension UserDeviceAPIClient.User.CompleteLoginChange {
  public struct Body: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case validationToken = "validationToken"
    }

    public let validationToken: String

    public init(validationToken: String) {
      self.validationToken = validationToken
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(validationToken, forKey: .validationToken)
    }
  }
}

extension UserDeviceAPIClient.User.CompleteLoginChange {
  public typealias Response = Empty?
}
