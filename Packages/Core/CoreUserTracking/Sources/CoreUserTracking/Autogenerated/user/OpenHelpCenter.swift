import Foundation

extension UserEvent {

  public struct `OpenHelpCenter`: Encodable, UserEventProtocol {
    public static let isPriority = false
    public init(`helpCenterArticleCta`: Definition.HelpCenterArticleCta? = nil) {
      self.helpCenterArticleCta = helpCenterArticleCta
    }
    public let helpCenterArticleCta: Definition.HelpCenterArticleCta?
    public let name = "open_help_center"
  }
}
