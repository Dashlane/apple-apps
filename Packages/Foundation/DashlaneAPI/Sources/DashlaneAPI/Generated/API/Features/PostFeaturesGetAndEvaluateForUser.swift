import Foundation

extension UserDeviceAPIClient.Features {
  public struct GetAndEvaluateForUser: APIRequest {
    public static let endpoint: Endpoint = "/features/GetAndEvaluateForUser"

    public let api: UserDeviceAPIClient

    public func callAsFunction(_ body: Body, timeout: TimeInterval? = nil) async throws -> Response
    {
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }

    public func callAsFunction(features: [String], timeout: TimeInterval? = nil) async throws
      -> Response
    {
      let body = Body(features: features)
      return try await api.post(Self.endpoint, body: body, timeout: timeout)
    }
  }
  public var getAndEvaluateForUser: GetAndEvaluateForUser {
    GetAndEvaluateForUser(api: api)
  }
}

extension UserDeviceAPIClient.Features.GetAndEvaluateForUser {
  public struct Body: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case features = "features"
    }

    public let features: [String]

    public init(features: [String]) {
      self.features = features
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(features, forKey: .features)
    }
  }
}

extension UserDeviceAPIClient.Features.GetAndEvaluateForUser {
  public struct Response: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case enabledFeatures = "enabledFeatures"
    }

    public let enabledFeatures: [String]

    public init(enabledFeatures: [String]) {
      self.enabledFeatures = enabledFeatures
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(enabledFeatures, forKey: .enabledFeatures)
    }
  }
}
