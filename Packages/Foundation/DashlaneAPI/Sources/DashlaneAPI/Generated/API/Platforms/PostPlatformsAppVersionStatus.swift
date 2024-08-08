import Foundation

extension AppAPIClient.Platforms {
  public struct AppVersionStatus: APIRequest {
    public static let endpoint: Endpoint = "/platforms/AppVersionStatus"

    public let api: AppAPIClient

    public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    public func callAsFunction(timeout: TimeInterval? = nil) async throws -> Response {
      let body = Body()
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var appVersionStatus: AppVersionStatus {
    AppVersionStatus(api: api)
  }
}

extension AppAPIClient.Platforms.AppVersionStatus {
  public typealias Body = Empty?
}

extension AppAPIClient.Platforms.AppVersionStatus {
  public struct Response: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case status = "status"
      case daysBeforeExpiration = "daysBeforeExpiration"
      case updatePossible = "updatePossible"
      case userSupportLink = "userSupportLink"
    }

    public enum Status: String, Sendable, Equatable, CaseIterable, Codable {
      case validVersion = "valid_version"
      case updateRecommended = "update_recommended"
      case updateStronglyEncouraged = "update_strongly_encouraged"
      case updateRequired = "update_required"
      case expiredVersion = "expired_version"
      case undecodable
      public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        self = Self(rawValue: rawValue) ?? .undecodable
      }
    }

    public let status: Status
    public let daysBeforeExpiration: Int
    public let updatePossible: Bool
    public let userSupportLink: String?

    public init(
      status: Status, daysBeforeExpiration: Int, updatePossible: Bool,
      userSupportLink: String? = nil
    ) {
      self.status = status
      self.daysBeforeExpiration = daysBeforeExpiration
      self.updatePossible = updatePossible
      self.userSupportLink = userSupportLink
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(status, forKey: .status)
      try container.encode(daysBeforeExpiration, forKey: .daysBeforeExpiration)
      try container.encode(updatePossible, forKey: .updatePossible)
      try container.encodeIfPresent(userSupportLink, forKey: .userSupportLink)
    }
  }
}
