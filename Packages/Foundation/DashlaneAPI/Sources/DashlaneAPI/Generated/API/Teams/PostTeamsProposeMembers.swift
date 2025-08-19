import Foundation

extension UserDeviceAPIClient.Teams {
  public struct ProposeMembers: APIRequest, Sendable {
    public static let endpoint: Endpoint = "/teams/ProposeMembers"

    public let api: UserDeviceAPIClient

    public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    public func callAsFunction(
      proposedMemberLogins: [String], force: Bool? = nil,
      notificationOptions: Body.NotificationOptions? = nil, origin: String? = nil,
      timeout: TimeInterval? = nil
    ) async throws -> Response {
      let body = Body(
        proposedMemberLogins: proposedMemberLogins, force: force,
        notificationOptions: notificationOptions, origin: origin)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var proposeMembers: ProposeMembers {
    ProposeMembers(api: api)
  }
}

extension UserDeviceAPIClient.Teams.ProposeMembers {
  public struct Body: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case proposedMemberLogins = "proposedMemberLogins"
      case force = "force"
      case notificationOptions = "notificationOptions"
      case origin = "origin"
    }

    public struct NotificationOptions: Codable, Hashable, Sendable {
      public enum CodingKeys: String, CodingKey {
        case senderEmail = "senderEmail"
        case skipAccountCreationRequiredAlerts = "skipAccountCreationRequiredAlerts"
        case skipProposals = "skipProposals"
        case skipRemovals = "skipRemovals"
        case skipReproposals = "skipReproposals"
      }

      public let senderEmail: String?
      public let skipAccountCreationRequiredAlerts: Bool?
      public let skipProposals: Bool?
      public let skipRemovals: Bool?
      public let skipReproposals: Bool?

      public init(
        senderEmail: String? = nil, skipAccountCreationRequiredAlerts: Bool? = nil,
        skipProposals: Bool? = nil, skipRemovals: Bool? = nil, skipReproposals: Bool? = nil
      ) {
        self.senderEmail = senderEmail
        self.skipAccountCreationRequiredAlerts = skipAccountCreationRequiredAlerts
        self.skipProposals = skipProposals
        self.skipRemovals = skipRemovals
        self.skipReproposals = skipReproposals
      }

      public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(senderEmail, forKey: .senderEmail)
        try container.encodeIfPresent(
          skipAccountCreationRequiredAlerts, forKey: .skipAccountCreationRequiredAlerts)
        try container.encodeIfPresent(skipProposals, forKey: .skipProposals)
        try container.encodeIfPresent(skipRemovals, forKey: .skipRemovals)
        try container.encodeIfPresent(skipReproposals, forKey: .skipReproposals)
      }
    }

    public let proposedMemberLogins: [String]
    public let force: Bool?
    public let notificationOptions: NotificationOptions?
    public let origin: String?

    public init(
      proposedMemberLogins: [String], force: Bool? = nil,
      notificationOptions: NotificationOptions? = nil, origin: String? = nil
    ) {
      self.proposedMemberLogins = proposedMemberLogins
      self.force = force
      self.notificationOptions = notificationOptions
      self.origin = origin
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(proposedMemberLogins, forKey: .proposedMemberLogins)
      try container.encodeIfPresent(force, forKey: .force)
      try container.encodeIfPresent(notificationOptions, forKey: .notificationOptions)
      try container.encodeIfPresent(origin, forKey: .origin)
    }
  }
}

extension UserDeviceAPIClient.Teams.ProposeMembers {
  public struct Response: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case proposedMembers = "proposedMembers"
      case refusedMembers = "refusedMembers"
      case accountCreationRequiredMembers = "accountCreationRequiredMembers"
    }

    public enum RefusedMembersValue: Codable, Hashable, Sendable {
      case boolean(Bool)
      case string(String)

      public var boolean: Bool? {
        guard case let .boolean(value) = self else {
          return nil
        }
        return value
      }

      public var string: String? {
        guard case let .string(value) = self else {
          return nil
        }
        return value
      }

      public init(from decoder: Decoder) throws {
        do {
          self = .boolean(try .init(from: decoder))
          return
        } catch {
        }
        do {
          self = .string(try .init(from: decoder))
          return
        } catch {
        }
        let context = DecodingError.Context(
          codingPath: decoder.codingPath,
          debugDescription: "No enum case can be decoded")
        throw DecodingError.typeMismatch(Self.self, context)
      }

      public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .boolean(let value):
          try container.encode(value)
        case .string(let value):
          try container.encode(value)
        }
      }
    }

    public let proposedMembers: [String: Bool]
    public let refusedMembers: [String: RefusedMembersValue]
    public let accountCreationRequiredMembers: [String]

    public init(
      proposedMembers: [String: Bool], refusedMembers: [String: RefusedMembersValue],
      accountCreationRequiredMembers: [String]
    ) {
      self.proposedMembers = proposedMembers
      self.refusedMembers = refusedMembers
      self.accountCreationRequiredMembers = accountCreationRequiredMembers
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(proposedMembers, forKey: .proposedMembers)
      try container.encode(refusedMembers, forKey: .refusedMembers)
      try container.encode(accountCreationRequiredMembers, forKey: .accountCreationRequiredMembers)
    }
  }
}
