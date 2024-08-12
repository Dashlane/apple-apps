import Foundation

extension Definition {

  public enum `DropdownType`: String, Encodable, Sendable {
    case `copy`
    case `quickActions` = "quick_actions"
  }
}
