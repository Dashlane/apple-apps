import DashlaneAPI
import Foundation

extension Status.B2cStatus {
  public var endDate: Date? {
    guard let endDateUnix else {
      return nil
    }
    return Date(timeIntervalSince1970: TimeInterval(endDateUnix))
  }
}

extension PremiumStatusTwoFAEnforced {
  public var isEnforced: Bool {
    switch self {
    case .newDevice, .login:
      return true
    case .disabled, .none, .undecodable:
      return false
    }
  }
}

extension CurrentTeam {
  public var isInStarterTeam: Bool {
    return planFeature == .starter
  }

  public var isAdminOfAStarterTeam: Bool {
    return planFeature == .starter && teamMembership.isTeamAdmin
  }

  public var isAdminOfABusinessTeamInTrial: Bool {
    return planFeature == .business && teamMembership.isTeamAdmin && isTrial == true
  }

  public var isRichIconsDisabled: Bool {
    return teamInfo.richIconsEnabled == false
  }
}

extension Status {
  public var isConcernedByStarterPlanSharingLimit: Bool {
    guard b2bStatus?.currentTeam?.isInStarterTeam == true else {
      return false
    }
    guard let collectionSharing = self.capabilities[.collectionSharing] else {
      return false
    }
    return collectionSharing.info?.whoCanShare == .adminOnly
  }

  public func hasSharingDisabledBecauseOfStarterPlanLimitation(alreadySharedCollectionsCount: Int)
    -> Bool
  {
    guard b2bStatus?.currentTeam?.isInStarterTeam == true, isConcernedByStarterPlanSharingLimit
    else {
      return false
    }
    guard b2bStatus?.currentTeam?.isAdminOfAStarterTeam == true else {
      return true
    }
    guard let limit = capabilities[.collectionSharing]?.info?.limit else {
      return false
    }

    return limit <= alreadySharedCollectionsCount
  }
}
