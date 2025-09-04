import Foundation

extension AppAPIClient.DarkwebmonitoringQA {
  public struct DeleteAllTestBreachEmails: APIRequest, Sendable {
    public static let endpoint: Endpoint = "/darkwebmonitoring-qa/DeleteAllTestBreachEmails"

    public let api: AppAPIClient

    @discardableResult public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil)
      async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    @discardableResult public func callAsFunction(breachUuid: String, timeout: TimeInterval? = nil)
      async throws -> Response
    {
      let body = Body(breachUuid: breachUuid)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var deleteAllTestBreachEmails: DeleteAllTestBreachEmails {
    DeleteAllTestBreachEmails(api: api)
  }
}

extension AppAPIClient.DarkwebmonitoringQA.DeleteAllTestBreachEmails {
  public struct Body: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case breachUuid = "breachUuid"
    }

    public let breachUuid: String

    public init(breachUuid: String) {
      self.breachUuid = breachUuid
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(breachUuid, forKey: .breachUuid)
    }
  }
}

extension AppAPIClient.DarkwebmonitoringQA.DeleteAllTestBreachEmails {
  public typealias Response = Empty?
}
