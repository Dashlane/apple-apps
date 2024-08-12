import CoreLocalization
import CoreSharing
import Foundation

extension L10n.Localizable {
  static func userCountRowTitle(forCount count: Int) -> String {
    if count < 2 {
      return L10n.Localizable.kwSharingUsersSingular(count)
    } else {
      return L10n.Localizable.kwSharingUsersPlural(count)
    }
  }

  static func userGroupCountRowTitle(forCount count: Int) -> String {
    if count < 2 {
      return L10n.Localizable.kwSharingUserGroupsSingular(count)
    } else {
      return L10n.Localizable.kwSharingUserGroupsPlural(count)
    }
  }

  static func userGroupMembersCountRowTitle(forCount count: Int) -> String {
    if count < 2 {
      return L10n.Localizable.kwSharingUserGroupMemberSingular(count)
    } else {
      return L10n.Localizable.kwSharingUserGroupMemberPlural(count)
    }
  }

  static func collectionCountRowTitle(forCount count: Int) -> String {
    if count < 2 {
      return L10n.Localizable.kwSharingCollectionsSingular(count)
    } else {
      return L10n.Localizable.kwSharingCollectionsPlural(count)
    }
  }
}

extension ItemSharingMembers {
  var localizedTitle: String? {
    var components: [String] = []
    if !users.isEmpty {
      components.append(L10n.Localizable.userCountRowTitle(forCount: users.count))
    }

    if !userGroupMembers.isEmpty {
      components.append(L10n.Localizable.userGroupCountRowTitle(forCount: userGroupMembers.count))
    }

    if !collectionMembers.isEmpty {
      components.append(L10n.Localizable.collectionCountRowTitle(forCount: collectionMembers.count))
    }

    guard !components.isEmpty else {
      return nil
    }

    return components.joined(separator: ", ")
  }
}
