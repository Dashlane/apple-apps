import Foundation

extension UserSpacesService.SpacesConfiguration {
  public func virtualUserSpace(forPersonalDataSpaceId spaceId: String?) -> UserSpace? {
    if let spaceId = spaceId, !spaceId.isEmpty {
      if let currentTeam, currentTeam.personalDataId == spaceId {
        return .team(currentTeam)
      } else if let pastTeam = b2bStatus?.pastTeams?.first(where: { $0.personalDataId == spaceId })
      {
        if pastTeam.teamInfo.shouldDeleteItemsOnRevoke
          || pastTeam.teamInfo.personalSpaceEnabled == false
        {
          return nil
        } else {
          return .personal
        }
      } else {
        return .personal
      }
    } else if availableSpaces.count == 1, let currentTeam {
      return .team(currentTeam)

    } else {
      return .personal
    }
  }
}
