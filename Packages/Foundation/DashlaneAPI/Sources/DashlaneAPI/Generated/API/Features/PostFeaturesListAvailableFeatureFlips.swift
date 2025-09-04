import Foundation

extension AppAPIClient.Features {
  public struct ListAvailableFeatureFlips: APIRequest, Sendable {
    public static let endpoint: Endpoint = "/features/ListAvailableFeatureFlips"

    public let api: AppAPIClient

    public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    public func callAsFunction(timeout: TimeInterval? = nil) async throws -> Response {
      let body = Body()
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var listAvailableFeatureFlips: ListAvailableFeatureFlips {
    ListAvailableFeatureFlips(api: api)
  }
}

extension AppAPIClient.Features.ListAvailableFeatureFlips {
  public typealias Body = Empty?
}

extension AppAPIClient.Features.ListAvailableFeatureFlips {
  public struct Response: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case features = "features"
    }

    public struct FeaturesElement: Codable, Hashable, Sendable {
      public enum CodingKeys: String, CodingKey {
        case name = "name"
        case archived = "archived"
      }

      public let name: String
      public let archived: Bool

      public init(name: String, archived: Bool) {
        self.name = name
        self.archived = archived
      }

      public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(archived, forKey: .archived)
      }
    }

    public let features: [FeaturesElement]

    public init(features: [FeaturesElement]) {
      self.features = features
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(features, forKey: .features)
    }
  }
}
