import Foundation

extension UserSecureNitroEncryptionAPIClient.Passkeys {
  public struct GetPasskeyLogs: APIRequest, Sendable {
    public static let endpoint: Endpoint = "/passkeys/GetPasskeyLogs"

    public let api: UserSecureNitroEncryptionAPIClient

    public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    public func callAsFunction(
      passkeyId: String, encryptionKey: PasskeysPasskeyEncryptionKey, timeout: TimeInterval? = nil
    ) async throws -> Response {
      let body = Body(passkeyId: passkeyId, encryptionKey: encryptionKey)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var getPasskeyLogs: GetPasskeyLogs {
    GetPasskeyLogs(api: api)
  }
}

extension UserSecureNitroEncryptionAPIClient.Passkeys.GetPasskeyLogs {
  public typealias Body = PasskeysPasskeyBody
}

extension UserSecureNitroEncryptionAPIClient.Passkeys.GetPasskeyLogs {
  public struct Response: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case passkeyId = "passkeyId"
      case creationEvent = "creationEvent"
      case requestEvents = "requestEvents"
    }

    public struct CreationEvent: Codable, Hashable, Sendable {
      public enum CodingKeys: String, CodingKey {
        case dateUnix = "dateUnix"
        case userLogin = "userLogin"
        case userId = "userId"
      }

      public let dateUnix: Int
      public let userLogin: String
      public let userId: Int

      public init(dateUnix: Int, userLogin: String, userId: Int) {
        self.dateUnix = dateUnix
        self.userLogin = userLogin
        self.userId = userId
      }

      public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(dateUnix, forKey: .dateUnix)
        try container.encode(userLogin, forKey: .userLogin)
        try container.encode(userId, forKey: .userId)
      }
    }

    public struct RequestEventsElement: Codable, Hashable, Sendable {
      public enum CodingKeys: String, CodingKey {
        case dateUnix = "dateUnix"
        case userLogin = "userLogin"
        case userId = "userId"
      }

      public let dateUnix: Int
      public let userLogin: String
      public let userId: Int

      public init(dateUnix: Int, userLogin: String, userId: Int) {
        self.dateUnix = dateUnix
        self.userLogin = userLogin
        self.userId = userId
      }

      public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(dateUnix, forKey: .dateUnix)
        try container.encode(userLogin, forKey: .userLogin)
        try container.encode(userId, forKey: .userId)
      }
    }

    public let passkeyId: String
    public let creationEvent: CreationEvent
    public let requestEvents: [RequestEventsElement]

    public init(
      passkeyId: String, creationEvent: CreationEvent, requestEvents: [RequestEventsElement]
    ) {
      self.passkeyId = passkeyId
      self.creationEvent = creationEvent
      self.requestEvents = requestEvents
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(passkeyId, forKey: .passkeyId)
      try container.encode(creationEvent, forKey: .creationEvent)
      try container.encode(requestEvents, forKey: .requestEvents)
    }
  }
}
