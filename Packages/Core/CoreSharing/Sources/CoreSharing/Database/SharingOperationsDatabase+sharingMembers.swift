import Foundation

extension SharingOperationsDatabase {
  func sharingMembers(forUserId userId: UserId, in group: ItemGroup) throws
    -> [any SharingGroupMember]
  {
    var members: [any SharingGroupMember] = []
    if let user = group.user(with: userId) {
      members.append(user)
    }

    for userGroupMember in group.userGroupMembers {
      guard
        let userGroupPair = try fetchUserGroupUserPair(
          withGroupId: userGroupMember.id, userId: userId), userGroupPair.user.status == .accepted
      else {
        continue
      }

      members.append(userGroupMember)
    }

    for collectionMember in group.collectionMembers {
      let collection = try fetchCollection(withId: collectionMember.id)
      let userGroupMembers = collection?.userGroupMembers ?? []
      let user = collection?.user(with: userId)

      if try user?.status == .accepted
        || userGroupMembers.contains(where: { userGroupMember in
          let userGroupUserPair = try fetchUserGroupUserPair(
            withGroupId: userGroupMember.id, userId: userId)
          return userGroupUserPair?.user.status == .accepted
        })
      {
        members.append(collectionMember)
      }
    }

    return members
  }

  func sharingMembers(forUserId userId: UserId, in collection: SharingCollection) throws
    -> [any SharingGroupMember]
  {
    var members: [any SharingGroupMember] = []
    if let user = collection.user(with: userId) {
      members.append(user)
    }

    for userGroupMember in collection.userGroupMembers {
      guard
        let userGroupPair = try fetchUserGroupUserPair(
          withGroupId: userGroupMember.id, userId: userId),
        userGroupPair.user.status == .accepted
      else {
        continue
      }

      members.append(userGroupMember)
    }

    return members
  }
}
