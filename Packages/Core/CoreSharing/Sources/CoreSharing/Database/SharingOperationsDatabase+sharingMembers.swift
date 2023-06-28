import Foundation

extension SharingOperationsDatabase {
        func sharingMembers(forUserId userId: UserId, in group: ItemGroup) throws -> [SharingGroupMember] {
        var members: [SharingGroupMember] = []
        if let user = group.user(with: userId) {
            members.append(user)
        }

        for userGroupMember in group.userGroupMembers {
                        guard let userGroupPair = try fetchUserGroupUserPair(withGroupId: userGroupMember.id, userId: userId), userGroupPair.user.status == .accepted else {
                continue
            }

            members.append(userGroupMember)
        }

        return members
    }
}
