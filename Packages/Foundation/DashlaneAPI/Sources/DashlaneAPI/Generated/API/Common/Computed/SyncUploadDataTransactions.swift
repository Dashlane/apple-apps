import Foundation

public struct SyncUploadDataTransactions: Codable, Hashable, Sendable {
  public enum CodingKeys: String, CodingKey {
    case identifier = "identifier"
    case time = "time"
    case content = "content"
    case type = "type"
    case action = "action"
  }

  public let identifier: String
  public let time: Int
  public let content: String
  public let type: String
  public let action: SyncDataAction

  public init(identifier: String, time: Int, content: String, type: String, action: SyncDataAction)
  {
    self.identifier = identifier
    self.time = time
    self.content = content
    self.type = type
    self.action = action
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(identifier, forKey: .identifier)
    try container.encode(time, forKey: .time)
    try container.encode(content, forKey: .content)
    try container.encode(type, forKey: .type)
    try container.encode(action, forKey: .action)
  }
}
