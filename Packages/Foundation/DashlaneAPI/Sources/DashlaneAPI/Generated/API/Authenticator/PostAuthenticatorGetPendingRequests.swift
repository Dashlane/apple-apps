import Foundation

extension UserDeviceAPIClient.Authenticator {
  public struct GetPendingRequests: APIRequest {
    public static let endpoint: Endpoint = "/authenticator/GetPendingRequests"

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
  public var getPendingRequests: GetPendingRequests {
    GetPendingRequests(api: api)
  }
}

extension UserDeviceAPIClient.Authenticator.GetPendingRequests {
  public typealias Body = Empty?
}

extension UserDeviceAPIClient.Authenticator.GetPendingRequests {
  public struct Response: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case requests = "requests"
    }

    public struct RequestsElement: Codable, Equatable, Sendable {
      public enum CodingKeys: String, CodingKey {
        case id = "id"
        case login = "login"
        case validity = "validity"
        case device = "device"
        case location = "location"
      }

      public struct Validity: Codable, Equatable, Sendable {
        public enum CodingKeys: String, CodingKey {
          case startDate = "startDate"
          case expireDate = "expireDate"
        }

        public let startDate: Int
        public let expireDate: Int

        public init(startDate: Int, expireDate: Int) {
          self.startDate = startDate
          self.expireDate = expireDate
        }

        public func encode(to encoder: Encoder) throws {
          var container = encoder.container(keyedBy: CodingKeys.self)
          try container.encode(startDate, forKey: .startDate)
          try container.encode(expireDate, forKey: .expireDate)
        }
      }

      public struct Device: Codable, Equatable, Sendable {
        public enum CodingKeys: String, CodingKey {
          case name = "name"
          case platform = "platform"
          case vendor = "vendor"
        }

        public let name: String?
        public let platform: String?
        public let vendor: String?

        public init(name: String? = nil, platform: String? = nil, vendor: String? = nil) {
          self.name = name
          self.platform = platform
          self.vendor = vendor
        }

        public func encode(to encoder: Encoder) throws {
          var container = encoder.container(keyedBy: CodingKeys.self)
          try container.encodeIfPresent(name, forKey: .name)
          try container.encodeIfPresent(platform, forKey: .platform)
          try container.encodeIfPresent(vendor, forKey: .vendor)
        }
      }

      public struct Location: Codable, Equatable, Sendable {
        public enum CodingKeys: String, CodingKey {
          case coordinate = "coordinate"
          case countryCode = "countryCode"
        }

        public struct Coordinate: Codable, Equatable, Sendable {
          public enum CodingKeys: String, CodingKey {
            case longitude = "longitude"
            case latitude = "latitude"
          }

          public let longitude: Int
          public let latitude: Int

          public init(longitude: Int, latitude: Int) {
            self.longitude = longitude
            self.latitude = latitude
          }

          public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(longitude, forKey: .longitude)
            try container.encode(latitude, forKey: .latitude)
          }
        }

        public let coordinate: Coordinate?
        public let countryCode: String?

        public init(coordinate: Coordinate? = nil, countryCode: String? = nil) {
          self.coordinate = coordinate
          self.countryCode = countryCode
        }

        public func encode(to encoder: Encoder) throws {
          var container = encoder.container(keyedBy: CodingKeys.self)
          try container.encodeIfPresent(coordinate, forKey: .coordinate)
          try container.encodeIfPresent(countryCode, forKey: .countryCode)
        }
      }

      public let id: String
      public let login: String
      public let validity: Validity
      public let device: Device
      public let location: Location

      public init(id: String, login: String, validity: Validity, device: Device, location: Location)
      {
        self.id = id
        self.login = login
        self.validity = validity
        self.device = device
        self.location = location
      }

      public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(login, forKey: .login)
        try container.encode(validity, forKey: .validity)
        try container.encode(device, forKey: .device)
        try container.encode(location, forKey: .location)
      }
    }

    public let requests: [RequestsElement]

    public init(requests: [RequestsElement]) {
      self.requests = requests
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(requests, forKey: .requests)
    }
  }
}
