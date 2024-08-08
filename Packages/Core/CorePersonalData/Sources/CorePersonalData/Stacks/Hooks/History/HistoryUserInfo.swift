import Foundation

public struct HistoryUserInfo {
  public let platform: String
  public let deviceName: String
  public let user: String

  public init(
    platform: String,
    deviceName: String,
    user: String
  ) {
    self.platform = platform
    self.deviceName = deviceName
    self.user = user
  }
}
