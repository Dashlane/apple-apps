import CoreLocalization
import CorePremium
import Foundation

extension UserSpace {
  public var teamName: String {
    switch self {
    case .personal:
      return L10n.Core.teamSpacesPersonalSpaceName
    case .both:
      return L10n.Core.teamSpacesAllSpaces
    case let .team(space):
      return space.teamInfo.name ?? ""
    }
  }

  public var letter: String? {
    switch self {
    case .personal:
      return L10n.Core.teamSpacesPersonalSpaceInitial
    case .both:
      return ""
    case let .team(team):
      return team.teamInfo.letter
    }
  }
}
