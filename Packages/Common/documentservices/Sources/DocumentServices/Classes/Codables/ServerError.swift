import Foundation
import LogFoundation

@Loggable
public struct ServerError: Error, Codable {
  public let code: Int
  @LogPublicPrivacy
  public let message: String
  @LogPublicPrivacy
  public let content: String?
}

extension ServerError {
  internal var isFileTooLarge: Bool {
    return content == "MAX_CONTENT_LENGTH_EXCEEDED"
  }
  public var isQuotaExceeded: Bool {
    return content == "QUOTA_EXCEEDED"
  }
}
