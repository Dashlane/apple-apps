import Foundation

extension UserDeviceAPIClient.Teams {
  public struct SpaceDeleted: APIRequest, Sendable {
    public static let endpoint: Endpoint = "/teams/SpaceDeleted"

    public let api: UserDeviceAPIClient

    @discardableResult public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil)
      async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    @discardableResult public func callAsFunction(teamId: Int, timeout: TimeInterval? = nil)
      async throws -> Response
    {
      let body = Body(teamId: teamId)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var spaceDeleted: SpaceDeleted {
    SpaceDeleted(api: api)
  }
}

extension UserDeviceAPIClient.Teams.SpaceDeleted {
  public struct Body: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case teamId = "teamId"
    }

    public let teamId: Int

    public init(teamId: Int) {
      self.teamId = teamId
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(teamId, forKey: .teamId)
    }
  }
}

extension UserDeviceAPIClient.Teams.SpaceDeleted {
  public typealias Response = Empty?
}
