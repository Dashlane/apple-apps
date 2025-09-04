import Foundation

extension UserDeviceAPIClient.Useractivity {
  public struct Create: APIRequest, Sendable {
    public static let endpoint: Endpoint = "/useractivity/Create"

    public let api: UserDeviceAPIClient

    @discardableResult public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil)
      async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    @discardableResult public func callAsFunction(
      relativeStart: Int, relativeEnd: Int, userActivity: UseractivityCreateActivity,
      teamActivity: Body.TeamActivity? = nil, timeout: TimeInterval? = nil
    ) async throws -> Response {
      let body = Body(
        relativeStart: relativeStart, relativeEnd: relativeEnd, userActivity: userActivity,
        teamActivity: teamActivity)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var create: Create {
    Create(api: api)
  }
}

extension UserDeviceAPIClient.Useractivity.Create {
  public struct Body: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case relativeStart = "relativeStart"
      case relativeEnd = "relativeEnd"
      case userActivity = "userActivity"
      case teamActivity = "teamActivity"
    }

    public struct TeamActivity: Codable, Hashable, Sendable {
      public enum CodingKeys: String, CodingKey {
        case teamId = "teamId"
        case activity = "activity"
      }

      public let teamId: Int
      public let activity: UseractivityCreateActivity

      public init(teamId: Int, activity: UseractivityCreateActivity) {
        self.teamId = teamId
        self.activity = activity
      }

      public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(teamId, forKey: .teamId)
        try container.encode(activity, forKey: .activity)
      }
    }

    public let relativeStart: Int
    public let relativeEnd: Int
    public let userActivity: UseractivityCreateActivity
    public let teamActivity: TeamActivity?

    public init(
      relativeStart: Int, relativeEnd: Int, userActivity: UseractivityCreateActivity,
      teamActivity: TeamActivity? = nil
    ) {
      self.relativeStart = relativeStart
      self.relativeEnd = relativeEnd
      self.userActivity = userActivity
      self.teamActivity = teamActivity
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(relativeStart, forKey: .relativeStart)
      try container.encode(relativeEnd, forKey: .relativeEnd)
      try container.encode(userActivity, forKey: .userActivity)
      try container.encodeIfPresent(teamActivity, forKey: .teamActivity)
    }
  }
}

extension UserDeviceAPIClient.Useractivity.Create {
  public typealias Response = Empty?
}
