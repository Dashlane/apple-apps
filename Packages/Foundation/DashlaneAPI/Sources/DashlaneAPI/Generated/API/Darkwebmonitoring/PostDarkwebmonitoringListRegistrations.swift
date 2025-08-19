import Foundation

extension UserDeviceAPIClient.Darkwebmonitoring {
  public struct ListRegistrations: APIRequest, Sendable {
    public static let endpoint: Endpoint = "/darkwebmonitoring/ListRegistrations"

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
  public var listRegistrations: ListRegistrations {
    ListRegistrations(api: api)
  }
}

extension UserDeviceAPIClient.Darkwebmonitoring.ListRegistrations {
  public typealias Body = Empty?
}

extension UserDeviceAPIClient.Darkwebmonitoring.ListRegistrations {
  public struct Response: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case emails = "emails"
    }

    public let emails: [DarkwebmonitoringListEmails]

    public init(emails: [DarkwebmonitoringListEmails]) {
      self.emails = emails
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(emails, forKey: .emails)
    }
  }
}
