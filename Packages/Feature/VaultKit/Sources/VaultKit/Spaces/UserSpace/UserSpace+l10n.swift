import CoreLocalization
import CorePremium
import Foundation

extension UserSpace {
  public var teamName: String {
    switch self {
    case .personal:
      return CoreL10n.teamSpacesPersonalSpaceName
    case .both:
      return CoreL10n.teamSpacesAllSpaces
    case let .team(space):
      return space.teamInfo.name ?? ""
    }
  }

  public var letter: String? {
    switch self {
    case .personal:
      return CoreL10n.teamSpacesPersonalSpaceInitial
    case .both:
      return ""
    case let .team(team):
      return team.teamInfo.letter
    }
  }
}
