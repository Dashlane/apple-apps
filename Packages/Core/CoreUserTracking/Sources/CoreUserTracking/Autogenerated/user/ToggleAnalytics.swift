import Foundation

extension UserEvent {

  public struct `ToggleAnalytics`: Encodable, UserEventProtocol {
    public static let isPriority = false
    public init(`isAnalyticsEnabled`: Bool) {
      self.isAnalyticsEnabled = isAnalyticsEnabled
    }
    public let isAnalyticsEnabled: Bool
    public let name = "toggle_analytics"
  }
}
