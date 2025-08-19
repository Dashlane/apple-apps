import Foundation

extension UserSecureNitroEncryptionAPIClient.Passkeys {
  public struct RegisterPasskey: APIRequest, Sendable {
    public static let endpoint: Endpoint = "/passkeys/RegisterPasskey"

    public let api: UserSecureNitroEncryptionAPIClient

    public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    public func callAsFunction(request: Body.Request, timeout: TimeInterval? = nil) async throws
      -> Response
    {
      let body = Body(request: request)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var registerPasskey: RegisterPasskey {
    RegisterPasskey(api: api)
  }
}

extension UserSecureNitroEncryptionAPIClient.Passkeys.RegisterPasskey {
  public struct Body: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case request = "request"
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
          case user = "user"
          case pubKeyCredParams = "pubKeyCredParams"
          case rp = "rp"
          case attestation = "attestation"
          case extensions = "extensions"
        }

        public struct User: Codable, Hashable, Sendable {
          public enum CodingKeys: String, CodingKey {
            case id = "id"
            case displayName = "displayName"
            case name = "name"
          }

          public let id: String
          public let displayName: String
          public let name: String

          public init(id: String, displayName: String, name: String) {
            self.id = id
            self.displayName = displayName
            self.name = name
          }

          public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(id, forKey: .id)
            try container.encode(displayName, forKey: .displayName)
            try container.encode(name, forKey: .name)
          }
        }

        public struct PubKeyCredParamsElement: Codable, Hashable, Sendable {
          public enum CodingKeys: String, CodingKey {
            case alg = "alg"
            case type = "type"
          }

          public let alg: Int
          public let type: PasskeysPasskeyType

          public init(alg: Int, type: PasskeysPasskeyType) {
            self.alg = alg
            self.type = type
          }

          public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(alg, forKey: .alg)
            try container.encode(type, forKey: .type)
          }
        }

        public struct Rp: Codable, Hashable, Sendable {
          public enum CodingKeys: String, CodingKey {
            case name = "name"
            case id = "id"
          }

          public let name: String
          public let id: String?

          public init(name: String, id: String? = nil) {
            self.name = name
            self.id = id
          }

          public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(name, forKey: .name)
            try container.encodeIfPresent(id, forKey: .id)
          }
        }

        public enum Attestation: String, Sendable, Hashable, Codable, CaseIterable {
          case direct = "direct"
          case enterprise = "enterprise"
          case indirect = "indirect"
          case none = "none"
          case undecodable
          public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let rawValue = try container.decode(String.self)
            self = Self(rawValue: rawValue) ?? .undecodable
          }
        }

        public let user: User
        public let pubKeyCredParams: [PubKeyCredParamsElement]
        public let rp: Rp
        public let attestation: Attestation?
        public let extensions: PasskeysPasskeyExtensions?

        public init(
          user: User, pubKeyCredParams: [PubKeyCredParamsElement], rp: Rp,
          attestation: Attestation? = nil, extensions: PasskeysPasskeyExtensions? = nil
        ) {
          self.user = user
          self.pubKeyCredParams = pubKeyCredParams
          self.rp = rp
          self.attestation = attestation
          self.extensions = extensions
        }

        public func encode(to encoder: Encoder) throws {
          var container = encoder.container(keyedBy: CodingKeys.self)
          try container.encode(user, forKey: .user)
          try container.encode(pubKeyCredParams, forKey: .pubKeyCredParams)
          try container.encode(rp, forKey: .rp)
          try container.encodeIfPresent(attestation, forKey: .attestation)
          try container.encodeIfPresent(extensions, forKey: .extensions)
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

    public init(request: Request) {
      self.request = request
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(request, forKey: .request)
    }
  }
}

extension UserSecureNitroEncryptionAPIClient.Passkeys.RegisterPasskey {
  public struct Response: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case passkeyId = "passkeyId"
      case encryptionKey = "encryptionKey"
      case credentialRegisterData = "credentialRegisterData"
    }

    public struct EncryptionKey: Codable, Hashable, Sendable {
      public enum CodingKeys: String, CodingKey {
        case uuid = "uuid"
        case key = "key"
      }

      public let uuid: String
      public let key: String

      public init(uuid: String, key: String) {
        self.uuid = uuid
        self.key = key
      }

      public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(uuid, forKey: .uuid)
        try container.encode(key, forKey: .key)
      }
    }

    public struct CredentialRegisterData: Codable, Hashable, Sendable {
      public enum CodingKeys: String, CodingKey {
        case type = "type"
        case rawId = "rawId"
        case id = "id"
        case clientDataHash = "clientDataHash"
        case attestationObject = "attestationObject"
        case authenticatorAttachment = "authenticatorAttachment"
        case authenticatorData = "authenticatorData"
        case publicKey = "publicKey"
        case publicKeyAlgorithm = "publicKeyAlgorithm"
        case transports = "transports"
        case clientExtensionResults = "clientExtensionResults"
      }

      public struct ClientExtensionResults: Codable, Hashable, Sendable {
        public enum CodingKeys: String, CodingKey {
          case appid = "appid"
          case credProps = "credProps"
          case hmacCreateSecret = "hmacCreateSecret"
        }

        public let appid: Bool?
        public let credProps: PasskeysPasskeyCredProps?
        public let hmacCreateSecret: Bool?

        public init(
          appid: Bool? = nil, credProps: PasskeysPasskeyCredProps? = nil,
          hmacCreateSecret: Bool? = nil
        ) {
          self.appid = appid
          self.credProps = credProps
          self.hmacCreateSecret = hmacCreateSecret
        }

        public func encode(to encoder: Encoder) throws {
          var container = encoder.container(keyedBy: CodingKeys.self)
          try container.encodeIfPresent(appid, forKey: .appid)
          try container.encodeIfPresent(credProps, forKey: .credProps)
          try container.encodeIfPresent(hmacCreateSecret, forKey: .hmacCreateSecret)
        }
      }

      public let type: PasskeysPasskeyType
      public let rawId: String
      public let id: String
      public let clientDataHash: String
      public let attestationObject: String
      public let authenticatorAttachment: String
      public let authenticatorData: String
      public let publicKey: String
      public let publicKeyAlgorithm: Int
      public let transports: [String]
      public let clientExtensionResults: ClientExtensionResults?

      public init(
        type: PasskeysPasskeyType, rawId: String, id: String, clientDataHash: String,
        attestationObject: String, authenticatorAttachment: String, authenticatorData: String,
        publicKey: String, publicKeyAlgorithm: Int, transports: [String],
        clientExtensionResults: ClientExtensionResults? = nil
      ) {
        self.type = type
        self.rawId = rawId
        self.id = id
        self.clientDataHash = clientDataHash
        self.attestationObject = attestationObject
        self.authenticatorAttachment = authenticatorAttachment
        self.authenticatorData = authenticatorData
        self.publicKey = publicKey
        self.publicKeyAlgorithm = publicKeyAlgorithm
        self.transports = transports
        self.clientExtensionResults = clientExtensionResults
      }

      public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encode(rawId, forKey: .rawId)
        try container.encode(id, forKey: .id)
        try container.encode(clientDataHash, forKey: .clientDataHash)
        try container.encode(attestationObject, forKey: .attestationObject)
        try container.encode(authenticatorAttachment, forKey: .authenticatorAttachment)
        try container.encode(authenticatorData, forKey: .authenticatorData)
        try container.encode(publicKey, forKey: .publicKey)
        try container.encode(publicKeyAlgorithm, forKey: .publicKeyAlgorithm)
        try container.encode(transports, forKey: .transports)
        try container.encodeIfPresent(clientExtensionResults, forKey: .clientExtensionResults)
      }
    }

    public let passkeyId: String
    public let encryptionKey: EncryptionKey
    public let credentialRegisterData: CredentialRegisterData

    public init(
      passkeyId: String, encryptionKey: EncryptionKey,
      credentialRegisterData: CredentialRegisterData
    ) {
      self.passkeyId = passkeyId
      self.encryptionKey = encryptionKey
      self.credentialRegisterData = credentialRegisterData
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(passkeyId, forKey: .passkeyId)
      try container.encode(encryptionKey, forKey: .encryptionKey)
      try container.encode(credentialRegisterData, forKey: .credentialRegisterData)
    }
  }
}
