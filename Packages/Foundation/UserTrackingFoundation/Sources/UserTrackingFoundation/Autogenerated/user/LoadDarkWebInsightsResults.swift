import Foundation

extension UserEvent {

  public struct `LoadDarkWebInsightsResults`: Encodable, UserEventProtocol {
    public static let isPriority = false
    public init() {

    }
    public let name = "load_dark_web_insights_results"
  }
}
