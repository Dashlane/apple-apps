import Foundation

extension UserEvent {

  public struct `FirstLaunch`: Encodable, UserEventProtocol {
    public static let isPriority = true
    public init(
      `android`: Definition.Android? = nil, `ios`: Definition.Ios? = nil,
      `isMarketingOptIn`: Bool? = nil,
      `web`: Definition.Web? = nil
    ) {
      self.android = android
      self.ios = ios
      self.isMarketingOptIn = isMarketingOptIn
      self.web = web
    }
    public let android: Definition.Android?
    public let ios: Definition.Ios?
    public let isMarketingOptIn: Bool?
    public let name = "first_launch"
    public let web: Definition.Web?
  }
}
