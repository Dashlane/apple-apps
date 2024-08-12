import DashlaneAPI
import Foundation

extension PremiumStatusTeamInfo {
  public func isValueMatchingDomains(_ value: String) -> Bool {
    guard forcedDomainsEnabled == true else {
      return false
    }

    let domains = teamDomains ?? []
    let value = value.lowercased()
    return domains.contains {
      value.contains($0)
    }
  }
}

extension Status.B2bStatus.CurrentTeam {
  public var personalDataId: String {
    String(teamId)
  }
}

extension Status.B2bStatus.PastTeamsElement {
  public var personalDataId: String {
    String(teamId)
  }
}
