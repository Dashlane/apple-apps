import Foundation

extension UserDeviceAPIClient.Invitation {
  public struct GetInvitationsHistory: APIRequest {
    public static let endpoint: Endpoint = "/invitation/GetInvitationsHistory"

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
  public var getInvitationsHistory: GetInvitationsHistory {
    GetInvitationsHistory(api: api)
  }
}

extension UserDeviceAPIClient.Invitation.GetInvitationsHistory {
  public typealias Body = Empty?
}

extension UserDeviceAPIClient.Invitation.GetInvitationsHistory {
  public struct Response: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case received = "received"
      case sent = "sent"
    }

    public struct ReceivedElement: Codable, Equatable, Sendable {
      public enum CodingKeys: String, CodingKey {
        case id = "id"
        case referrerUserId = "referrerUserId"
        case referrerLogin = "referrerLogin"
        case creationDateUnix = "creationDateUnix"
        case type = "type"
      }

      public let id: Int
      public let referrerUserId: Int
      public let referrerLogin: String
      public let creationDateUnix: Int
      public let type: String

      public init(
        id: Int, referrerUserId: Int, referrerLogin: String, creationDateUnix: Int, type: String
      ) {
        self.id = id
        self.referrerUserId = referrerUserId
        self.referrerLogin = referrerLogin
        self.creationDateUnix = creationDateUnix
        self.type = type
      }

      public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(referrerUserId, forKey: .referrerUserId)
        try container.encode(referrerLogin, forKey: .referrerLogin)
        try container.encode(creationDateUnix, forKey: .creationDateUnix)
        try container.encode(type, forKey: .type)
      }
    }

    public struct SentElement: Codable, Equatable, Sendable {
      public enum CodingKeys: String, CodingKey {
        case id = "id"
        case inviteeUserId = "inviteeUserId"
        case inviteeLogin = "inviteeLogin"
        case creationDateUnix = "creationDateUnix"
        case accountCreationDateUnix = "accountCreationDateUnix"
        case type = "type"
      }

      public let id: Int
      public let inviteeUserId: Int
      public let inviteeLogin: String
      public let creationDateUnix: Int
      public let accountCreationDateUnix: Int?
      public let type: String

      public init(
        id: Int, inviteeUserId: Int, inviteeLogin: String, creationDateUnix: Int,
        accountCreationDateUnix: Int?, type: String
      ) {
        self.id = id
        self.inviteeUserId = inviteeUserId
        self.inviteeLogin = inviteeLogin
        self.creationDateUnix = creationDateUnix
        self.accountCreationDateUnix = accountCreationDateUnix
        self.type = type
      }

      public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(inviteeUserId, forKey: .inviteeUserId)
        try container.encode(inviteeLogin, forKey: .inviteeLogin)
        try container.encode(creationDateUnix, forKey: .creationDateUnix)
        try container.encode(accountCreationDateUnix, forKey: .accountCreationDateUnix)
        try container.encode(type, forKey: .type)
      }
    }

    public let received: [ReceivedElement]
    public let sent: [SentElement]

    public init(received: [ReceivedElement], sent: [SentElement]) {
      self.received = received
      self.sent = sent
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(received, forKey: .received)
      try container.encode(sent, forKey: .sent)
    }
  }
}
