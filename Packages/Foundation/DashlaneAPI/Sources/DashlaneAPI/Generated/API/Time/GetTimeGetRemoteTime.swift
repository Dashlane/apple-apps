import Foundation

extension UnsignedAPIClient.Time {
  public struct GetRemoteTime: APIRequest {
    public static let endpoint: Endpoint = "/time/GetRemoteTime"

    public let api: UnsignedAPIClient

    public func callAsFunction(timeout: TimeInterval? = nil) async throws -> Response {
      return try await api.get(Self.endpoint, timeout: timeout)
    }
  }
  public var getRemoteTime: GetRemoteTime {
    GetRemoteTime(api: api)
  }
}

extension UnsignedAPIClient.Time.GetRemoteTime {
  public struct Response: Codable, Equatable, Sendable {
    public enum CodingKeys: String, CodingKey {
      case timestamp = "timestamp"
    }

    public let timestamp: Int

    public init(timestamp: Int) {
      self.timestamp = timestamp
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      try container.encode(timestamp, forKey: .timestamp)
    }
  }
}
