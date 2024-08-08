import CorePersonalData
import CorePremium
import DashlaneAPI
import Foundation

extension UserSpacesService.SpacesConfiguration {
  public func virtualUserSpace(for item: VaultItem) -> UserSpace? {
    virtualUserSpace(forPersonalDataSpaceId: item.spaceId)
  }

  public func virtualUserSpace(for collection: PrivateCollection) -> UserSpace? {
    virtualUserSpace(forPersonalDataSpaceId: collection.spaceId)
  }

  public func virtualUserSpace(for collection: VaultCollection) -> UserSpace? {
    virtualUserSpace(forPersonalDataSpaceId: collection.spaceId)
  }
}

extension UserSpacesService.SpacesConfiguration {
  public func editingUserSpace(for item: VaultItem) -> UserSpace {
    if let space = forcedSpace(for: item) {
      return space
    } else {
      return virtualUserSpace(for: item) ?? defaultSpace(for: item)
    }
  }
}

extension UserSpacesService.SpacesConfiguration {
  public func shouldDisplay(_ item: VaultItem) -> Bool {
    guard let space = virtualUserSpace(for: item) else {
      return false
    }

    return selectedSpace.match(space)
  }

  public func shouldDisplay(_ item: PrivateCollection) -> Bool {
    guard let space = virtualUserSpace(for: item) else {
      return false
    }

    return selectedSpace.match(space)
  }
}

extension UserSpacesService.SpacesConfiguration {
  public func canSelectSpace(for item: VaultItem) -> Bool {
    guard availableSpaces.count > 1 else {
      return false
    }

    guard let team = currentTeam, team.teamInfo.forcedDomainsEnabled == true else {
      return true
    }

    return !item.isAssociated(to: team.teamInfo)
  }

  public func defaultSpace(for item: VaultItem) -> UserSpace {
    if let team = currentTeam {
      return .team(team)
    } else {
      return selectedSpace
    }
  }

  public func forcedSpace(for item: VaultItem) -> UserSpace? {
    guard !canSelectSpace(for: item) else {
      return nil
    }

    return defaultSpace(for: item)
  }
}

extension UserSpacesService.SpacesConfiguration {
  public func displayedUserSpace(for item: VaultItem) -> UserSpace? {
    guard availableSpaces.count > 1 else {
      return nil
    }

    let itemSpace = virtualUserSpace(for: item)
    return selectedSpace != itemSpace ? itemSpace : nil
  }

  public func displayedUserSpace(for collection: PrivateCollection) -> UserSpace? {
    guard availableSpaces.count > 1 else {
      return nil
    }

    let collectionSpace = virtualUserSpace(for: collection)
    return selectedSpace != collectionSpace ? collectionSpace : nil
  }

  public func displayedUserSpace(for collection: VaultCollection) -> UserSpace? {
    guard availableSpaces.count > 1 else {
      return nil
    }

    let collectionSpace = virtualUserSpace(for: collection)
    return selectedSpace != collectionSpace ? collectionSpace : nil
  }
}

extension UserSpacesService.SpacesConfiguration {
  public func team(for item: VaultItem) -> CorePremium.Status.B2bStatus.CurrentTeam? {
    guard let userSpace = virtualUserSpace(for: item), case let UserSpace.team(team) = userSpace
    else {
      return nil
    }

    return team
  }
}
