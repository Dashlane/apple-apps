import Foundation

extension UserSecureNitroEncryptionAPIClient.Passkeys {
  public struct UsePasskey: APIRequest, Sendable {
    public static let endpoint: Endpoint = "/passkeys/UsePasskey"

    public let api: UserSecureNitroEncryptionAPIClient

    public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    public func callAsFunction(
      request: Body.Request, passkeyId: String, encryptionKey: PasskeysPasskeyEncryptionKey,
      timeout: TimeInterval? = nil
    ) async throws -> Response {
      let body = Body(request: request, passkeyId: passkeyId, encryptionKey: encryptionKey)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var usePasskey: UsePasskey {
    UsePasskey(api: api)
  }
}

extension UserSecureNitroEncryptionAPIClient.Passkeys.UsePasskey {
  public struct Body: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case request = "request"
      case passkeyId = "passkeyId"
      case encryptionKey = "encryptionKey"
    }

    public struct Request: Codable, Hashable, Sendable {
      public enum CodingKeys: String, CodingKey {
        case clientDataHash = "clientDataHash"
        case origin = "origin"
        case options = "options"
        case userVerificationDone = "userVerificationDone"
      }

      public struct Options: Codable, Hashable, Sendable {
        public enum CodingKeys: String, CodingKey {
          case extensions = "extensions"
          case rpId = "rpId"
        }

        public let extensions: PasskeysPasskeyExtensions?
        public let rpId: String?

        public init(extensions: PasskeysPasskeyExtensions? = nil, rpId: String? = nil) {
          self.extensions = extensions
          self.rpId = rpId
        }

        public func encode(to encoder: Encoder) throws {
          var container = encoder.container(keyedBy: CodingKeys.self)
          try container.encodeIfPresent(extensions, forKey: .extensions)
          try container.encodeIfPresent(rpId, forKey: .rpId)
        }
      }

      public let clientDataHash: String
      public let origin: String
      public let options: Options
      public let userVerificationDone: Bool?

      public init(
        clientDataHash: String, origin: String, options: Options, userVerificationDone: Bool? = nil
      ) {
        self.clientDataHash = clientDataHash
        self.origin = origin
        self.options = options
        self.userVerificationDone = userVerificationDone
      }

      public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(clientDataHash, forKey: .clientDataHash)
        try container.encode(origin, forKey: .origin)
        try container.encode(options, forKey: .options)
        try container.encodeIfPresent(userVerificationDone, forKey: .userVerificationDone)
      }
    }

    public let request: Request
    public let passkeyId: String
    public let encryptionKey: PasskeysPasskeyEncryptionKey

    public init(request: Request, passkeyId: String, encryptionKey: PasskeysPasskeyEncryptionKey) {
      self.request = request
      self.passkeyId = passkeyId
      self.encryptionKey = encryptionKey
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(request, forKey: .request)
      try container.encode(passkeyId, forKey: .passkeyId)
      try container.encode(encryptionKey, forKey: .encryptionKey)
    }
  }
}

extension UserSecureNitroEncryptionAPIClient.Passkeys.UsePasskey {
  public struct Response: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case credentialGetData = "credentialGetData"
      case requestEvents = "requestEvents"
    }

    public struct CredentialGetData: Codable, Hashable, Sendable {
      public enum CodingKeys: String, CodingKey {
        case authenticatorAttachment = "authenticatorAttachment"
        case id = "id"
        case type = "type"
        case rawId = "rawId"
        case response = "response"
        case clientExtensionResults = "clientExtensionResults"
      }

      public struct Response: Codable, Hashable, Sendable {
        public enum CodingKeys: String, CodingKey {
          case authenticatorData = "authenticatorData"
          case clientDataHash = "clientDataHash"
          case signature = "signature"
          case userHandle = "userHandle"
        }

        public let authenticatorData: String
        public let clientDataHash: String
        public let signature: String
        public let userHandle: String?

        public init(
          authenticatorData: String, clientDataHash: String, signature: String,
          userHandle: String? = nil
        ) {
          self.authenticatorData = authenticatorData
          self.clientDataHash = clientDataHash
          self.signature = signature
          self.userHandle = userHandle
        }

        public func encode(to encoder: Encoder) throws {
          var container = encoder.container(keyedBy: CodingKeys.self)
          try container.encode(authenticatorData, forKey: .authenticatorData)
          try container.encode(clientDataHash, forKey: .clientDataHash)
          try container.encode(signature, forKey: .signature)
          try container.encodeIfPresent(userHandle, forKey: .userHandle)
        }
      }

      public struct ClientExtensionResults: Codable, Hashable, Sendable {
        public enum CodingKeys: String, CodingKey {
          case credProps = "credProps"
        }

        public let credProps: PasskeysPasskeyCredProps?

        public init(credProps: PasskeysPasskeyCredProps? = nil) {
          self.credProps = credProps
        }

        public func encode(to encoder: Encoder) throws {
          var container = encoder.container(keyedBy: CodingKeys.self)
          try container.encodeIfPresent(credProps, forKey: .credProps)
        }
      }

      public let authenticatorAttachment: String?
      public let id: String
      public let type: PasskeysPasskeyType
      public let rawId: String
      public let response: Response
      public let clientExtensionResults: ClientExtensionResults?

      public init(
        authenticatorAttachment: String?, id: String, type: PasskeysPasskeyType, rawId: String,
        response: Response, clientExtensionResults: ClientExtensionResults? = nil
      ) {
        self.authenticatorAttachment = authenticatorAttachment
        self.id = id
        self.type = type
        self.rawId = rawId
        self.response = response
        self.clientExtensionResults = clientExtensionResults
      }

      public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(authenticatorAttachment, forKey: .authenticatorAttachment)
        try container.encode(id, forKey: .id)
        try container.encode(type, forKey: .type)
        try container.encode(rawId, forKey: .rawId)
        try container.encode(response, forKey: .response)
        try container.encodeIfPresent(clientExtensionResults, forKey: .clientExtensionResults)
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

    public let credentialGetData: CredentialGetData
    public let requestEvents: [RequestEventsElement]

    public init(credentialGetData: CredentialGetData, requestEvents: [RequestEventsElement]) {
      self.credentialGetData = credentialGetData
      self.requestEvents = requestEvents
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(credentialGetData, forKey: .credentialGetData)
      try container.encode(requestEvents, forKey: .requestEvents)
    }
  }
}
