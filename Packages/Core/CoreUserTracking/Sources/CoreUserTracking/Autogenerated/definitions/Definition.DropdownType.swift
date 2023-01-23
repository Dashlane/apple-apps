import Foundation

extension Definition {

public enum `DropdownType`: String, Encodable {
case `copy`
case `quickActions` = "quick_actions"
}
}