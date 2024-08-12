import Foundation

extension AppAPIClient.DarkwebmonitoringQA {
  public struct AddTestLeak: APIRequest {
    public static let endpoint: Endpoint = "/darkwebmonitoring-qa/AddTestLeak"

    public let api: AppAPIClient

    @discardableResult public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil)
      async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    @discardableResult public func callAsFunction(leak: Body.Leak, timeout: TimeInterval? = nil)
      async throws -> Response
    {
      let body = Body(leak: leak)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var addTestLeak: AddTestLeak {
    AddTestLeak(api: api)
  }
}

extension AppAPIClient.DarkwebmonitoringQA.AddTestLeak {
  public struct Body: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case leak = "leak"
    }

    public struct Leak: Codable, Equatable, Sendable {
      public enum CodingKeys: String, CodingKey {
        case uuid = "uuid"
        case email = "email"
        case fields = "fields"
        case types = "types"
      }

      public struct FieldsElement: Codable, Equatable, Sendable {
        public enum CodingKeys: String, CodingKey {
          case field = "field"
          case value = "value"
        }

        public enum Field: String, Sendable, Equatable, CaseIterable, Codable {
          case password = "password"
          case passwordPlaintext = "password_plaintext"
          case salt = "salt"
          case passwordType = "password_type"
          case email = "email"
          case username = "username"
          case phone = "phone"
          case address1 = "address_1"
          case address2 = "address_2"
          case city = "city"
          case country = "country"
          case county = "county"
          case state = "state"
          case postalCode = "postal_code"
          case ccBin = "cc_bin"
          case ccCode = "cc_code"
          case ccExpiration = "cc_expiration"
          case ccLastFour = "cc_last_four"
          case ccType = "cc_type"
          case ipAddresses = "ip_addresses"
          case geolocation = "geolocation"
          case age = "age"
          case fullName = "full_name"
          case gender = "gender"
          case language = "language"
          case timezone = "timezone"
          case dob = "dob"
          case socialAim = "social_aim"
          case socialFacebook = "social_facebook"
          case socialGithub = "social_github"
          case socialGoogle = "social_google"
          case socialIcq = "social_icq"
          case socialInstagram = "social_instagram"
          case socialLinkedin = "social_linkedin"
          case socialMsn = "social_msn"
          case socialMyspace = "social_myspace"
          case socialOther = "social_other"
          case socialSkype = "social_skype"
          case socialTelegram = "social_telegram"
          case socialTwitter = "social_twitter"
          case socialWhatsapp = "social_whatsapp"
          case socialYahoo = "social_yahoo"
          case socialYoutube = "social_youtube"
          case undecodable
          public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let rawValue = try container.decode(String.self)
            self = Self(rawValue: rawValue) ?? .undecodable
          }
        }

        public let field: Field
        public let value: String

        public init(field: Field, value: String) {
          self.field = field
          self.value = value
        }

        public func encode(to encoder: Encoder) throws {
          var container = encoder.container(keyedBy: CodingKeys.self)
          try container.encode(field, forKey: .field)
          try container.encode(value, forKey: .value)
        }
      }

      public enum TypesElement: String, Sendable, Equatable, CaseIterable, Codable {
        case phone = "phone"
        case password = "password"
        case email = "email"
        case username = "username"
        case creditcard = "creditcard"
        case address = "address"
        case ip = "ip"
        case geolocation = "geolocation"
        case personalinfo = "personalinfo"
        case social = "social"
        case undecodable
        public init(from decoder: Decoder) throws {
          let container = try decoder.singleValueContainer()
          let rawValue = try container.decode(String.self)
          self = Self(rawValue: rawValue) ?? .undecodable
        }
      }

      public let uuid: String
      public let email: String
      public let fields: [FieldsElement]
      public let types: [TypesElement]

      public init(uuid: String, email: String, fields: [FieldsElement], types: [TypesElement]) {
        self.uuid = uuid
        self.email = email
        self.fields = fields
        self.types = types
      }

      public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(uuid, forKey: .uuid)
        try container.encode(email, forKey: .email)
        try container.encode(fields, forKey: .fields)
        try container.encode(types, forKey: .types)
      }
    }

    public let leak: Leak

    public init(leak: Leak) {
      self.leak = leak
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(leak, forKey: .leak)
    }
  }
}

extension AppAPIClient.DarkwebmonitoringQA.AddTestLeak {
  public typealias Response = Empty?
}
