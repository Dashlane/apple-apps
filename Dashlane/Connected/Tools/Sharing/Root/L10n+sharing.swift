import Foundation
import CoreLocalization
import CoreSharing

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
}

extension ItemSharingMembers {
    var localizedTitle: String? {
        var components: [String] = []
        if users.count > 0 {
            components.append(L10n.Localizable.userCountRowTitle(forCount: users.count))
        }

        if userGroupMembers.count > 0 {
            components.append(L10n.Localizable.userGroupCountRowTitle(forCount: userGroupMembers.count))
        }

        guard !components.isEmpty else {
            return nil
        }

        return components.joined(separator: " ,")
    }
}
