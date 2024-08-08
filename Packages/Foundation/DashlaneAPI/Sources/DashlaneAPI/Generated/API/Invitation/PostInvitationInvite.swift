import Foundation

extension AppAPIClient.Invitation {
  public struct Invite: APIRequest {
    public static let endpoint: Endpoint = "/invitation/Invite"

    public let api: AppAPIClient

    @discardableResult public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil)
      async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    @discardableResult public func callAsFunction(
      userKey: String, identifiers: [String], type: String, language: String? = nil,
      message: String? = nil, name: String? = nil, timeout: TimeInterval? = nil
    ) async throws -> Response {
      let body = Body(
        userKey: userKey, identifiers: identifiers, type: type, language: language,
        message: message, name: name)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var invite: Invite {
    Invite(api: api)
  }
}

extension AppAPIClient.Invitation.Invite {
  public struct Body: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case userKey = "userKey"
      case identifiers = "identifiers"
      case type = "type"
      case language = "language"
      case message = "message"
      case name = "name"
    }

    public let userKey: String
    public let identifiers: [String]
    public let type: String
    public let language: String?
    public let message: String?
    public let name: String?

    public init(
      userKey: String, identifiers: [String], type: String, language: String? = nil,
      message: String? = nil, name: String? = nil
    ) {
      self.userKey = userKey
      self.identifiers = identifiers
      self.type = type
      self.language = language
      self.message = message
      self.name = name
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(userKey, forKey: .userKey)
      try container.encode(identifiers, forKey: .identifiers)
      try container.encode(type, forKey: .type)
      try container.encodeIfPresent(language, forKey: .language)
      try container.encodeIfPresent(message, forKey: .message)
      try container.encodeIfPresent(name, forKey: .name)
    }
  }
}

extension AppAPIClient.Invitation.Invite {
  public typealias Response = Empty?
}
