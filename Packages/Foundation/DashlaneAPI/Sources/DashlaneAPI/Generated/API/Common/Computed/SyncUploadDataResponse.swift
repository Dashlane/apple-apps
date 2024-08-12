import Foundation

public struct SyncUploadDataResponse: Codable, Equatable, Sendable {
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
