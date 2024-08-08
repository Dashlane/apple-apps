import Foundation

public struct ServerError: Error, Codable {
  public let code: Int
  public let message: String
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
