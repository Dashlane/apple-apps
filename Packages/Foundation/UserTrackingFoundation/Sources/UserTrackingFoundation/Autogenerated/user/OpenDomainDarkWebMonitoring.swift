import Foundation

extension UserEvent {

  public struct `OpenDomainDarkWebMonitoring`: Encodable, UserEventProtocol {
    public static let isPriority = false
    public init(`accessPath`: Definition.AccessPath, `isFirstVisit`: Bool) {
      self.accessPath = accessPath
      self.isFirstVisit = isFirstVisit
    }
    public let accessPath: Definition.AccessPath
    public let isFirstVisit: Bool
    public let name = "open_domain_dark_web_monitoring"
  }
}
