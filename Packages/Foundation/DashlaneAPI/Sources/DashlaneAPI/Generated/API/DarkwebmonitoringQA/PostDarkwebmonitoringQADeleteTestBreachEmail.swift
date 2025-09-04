import Foundation

extension AppAPIClient.DarkwebmonitoringQA {
  public struct DeleteTestBreachEmail: APIRequest, Sendable {
    public static let endpoint: Endpoint = "/darkwebmonitoring-qa/DeleteTestBreachEmail"

    public let api: AppAPIClient

    @discardableResult public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil)
      async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    @discardableResult public func callAsFunction(
      breachUuid: String, email: String, timeout: TimeInterval? = nil
    ) async throws -> Response {
      let body = Body(breachUuid: breachUuid, email: email)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var deleteTestBreachEmail: DeleteTestBreachEmail {
    DeleteTestBreachEmail(api: api)
  }
}

extension AppAPIClient.DarkwebmonitoringQA.DeleteTestBreachEmail {
  public struct Body: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case breachUuid = "breachUuid"
      case email = "email"
    }

    public let breachUuid: String
    public let email: String

    public init(breachUuid: String, email: String) {
      self.breachUuid = breachUuid
      self.email = email
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(breachUuid, forKey: .breachUuid)
      try container.encode(email, forKey: .email)
    }
  }
}

extension AppAPIClient.DarkwebmonitoringQA.DeleteTestBreachEmail {
  public typealias Response = Empty?
}
