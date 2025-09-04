import Foundation

extension AppAPIClient.Features {
  public struct ListAvailableLabs: APIRequest, Sendable {
    public static let endpoint: Endpoint = "/features/ListAvailableLabs"

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
  public var listAvailableLabs: ListAvailableLabs {
    ListAvailableLabs(api: api)
  }
}

extension AppAPIClient.Features.ListAvailableLabs {
  public typealias Body = Empty?
}

extension AppAPIClient.Features.ListAvailableLabs {
  public struct Response: Codable, Hashable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case labs = "labs"
    }

    public struct LabsElement: Codable, Hashable, Sendable {
      public enum CodingKeys: String, CodingKey {
        case featureName = "featureName"
        case displayName = "displayName"
        case displayDescription = "displayDescription"
      }

      public let featureName: String
      public let displayName: String
      public let displayDescription: String

      public init(featureName: String, displayName: String, displayDescription: String) {
        self.featureName = featureName
        self.displayName = displayName
        self.displayDescription = displayDescription
      }

      public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(featureName, forKey: .featureName)
        try container.encode(displayName, forKey: .displayName)
        try container.encode(displayDescription, forKey: .displayDescription)
      }
    }

    public let labs: [LabsElement]

    public init(labs: [LabsElement]) {
      self.labs = labs
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(labs, forKey: .labs)
    }
  }
}
