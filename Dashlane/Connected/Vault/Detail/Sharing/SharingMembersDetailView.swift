import CoreLocalization
import CorePersonalData
import CoreSharing
import DashTypes
import DesignSystem
import SwiftUI
import UIComponents
import VaultKit

struct SharingMembersDetailView: View {
  @StateObject
  var model: SharingMembersDetailViewModel

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      if model.anyMemberSharedThroughCollection {
        Infobox(
          CoreLocalization.L10n.Core.kwSharingCenterRecipientsPermissionTitle,
          description: CoreLocalization.L10n.Core.kwSharingCenterRecipientsPermissionText
        )
        .padding()
      }

      List {
        if !model.members.collectionMembers.isEmpty {
          collectionsList
        }
        if !model.members.userGroupMembers.isEmpty || !model.members.users.isEmpty {
          peopleList
        }
      }
      .scrollContentBackground(.hidden)
      .listStyle(.insetGrouped)
    }
    .background(.ds.background.alternate)
    .toolbar { toolbarContent }
    .navigationBarTitleDisplayMode(.inline)
    .navigationTitle(L10n.Localizable.tabContactsTitle)
    .alert(item: $model.alertMessage) { message in
      Alert(title: Text(message))
    }
  }

  @ToolbarContentBuilder
  var toolbarContent: some ToolbarContent {
    ToolbarItem(placement: .navigationBarTrailing) {
      trailingButton
    }
  }

  @ViewBuilder
  private var trailingButton: some View {
    if model.isSharingReady, model.permission == .admin {
      ShareButton(model: model.makeShareButtonModelFactory()) {
        Image(systemName: "plus.circle.fill")
      }
    } else {
      Spacer()
    }
  }

  var collectionsList: some View {
    LargeHeaderSection(title: L10n.Localizable.kwSharingCenterSectionCollections) {
      ForEach(model.members.collectionMembers) { collection in
        SharingToolRecipientRow(title: collection.name, subtitle: collection.localizedStatus) {
          Thumbnail.collection
            .controlSize(.small)
        }
      }
    }
  }

  var peopleList: some View {
    LargeHeaderSection(title: L10n.Localizable.kwSharingCenterSectionUsersAndGroups) {
      usersList
      userGroupsList
    }
  }

  var userGroupsList: some View {
    ForEach(model.members.userGroupMembers) { userGroup in
      HStack {
        let isAdmin = model.permission == .admin
        SharingToolRecipientRow(title: userGroup.name, subtitle: userGroup.localizedStatus) {
          Thumbnail.User.group
            .controlSize(.small)
        }
        .contextMenu {
          if isAdmin {
            userGroupMenuContent(for: userGroup)
              .disabled(!model.isSharedDirectly(userGroup))
          }
        }
        if isAdmin {
          let isInProgress = model.inProgressGroupActionIds.contains(userGroup.id)
          Menu {
            userGroupMenuContent(for: userGroup)
          } label: {
            SharingEditLabel(isInProgress: isInProgress)
          }
          .disabled(isInProgress)
        }
      }
      .onRevokeSharing {
        model.revoke(userGroup)
      }
    }
  }

  @ViewBuilder
  func userGroupMenuContent(for userGroup: UserGroupMember<ItemGroup>) -> some View {
    RevokeSharingButton()

    ChangeSharingPermissionButton(currentPermission: userGroup.permission) { permission in
      model.changePermission(for: userGroup, to: permission)
    }
  }

  var usersList: some View {
    ForEach(model.members.users) { user in
      HStack {
        let shouldShowMenu = model.permission == .admin && user.id != model.currentUserId
        SharingToolRecipientRow(title: user.id, subtitle: user.localizedStatus) {
          GravatarIconView(model: model.gravatarViewModelFactory.make(email: user.id))
        }
        .contextMenu {
          if shouldShowMenu {
            userMenuContent(for: user)
          }
        }

        if shouldShowMenu {
          let isInProgress = model.inProgressUserActionIds.contains(user.id)
          Menu {
            userMenuContent(for: user)
              .disabled(!model.isSharedDirectly(user))
          } label: {
            SharingEditLabel(isInProgress: isInProgress)
          }
          .disabled(isInProgress)
        }
      }
      .onRevokeSharing {
        model.revoke(user)
      }
    }
  }

  @ViewBuilder
  func userMenuContent(for user: User<ItemGroup>) -> some View {
    if user.status == .pending {
      Button(L10n.Localizable.kwResendGroupInvite) {
        model.resendInvite(for: user)
      }
    }

    RevokeSharingButton()

    ChangeSharingPermissionButton(currentPermission: user.permission) { permission in
      model.changePermission(for: user, to: permission)
    }
  }
}

#Preview {
  NavigationView {
    SharingMembersDetailView(
      model: .init(
        members: .init(
          itemGroupInfo: .mock(),
          users: .users,
          userGroupMembers: .userGroups,
          collectionMembers: .collections
        ),
        item: PersonalDataMock.Credentials.sharedAdminPermissionCredential,
        session: .mock,
        personalDataBD: ApplicationDBStack.mock(),
        gravatarViewModelFactory: .init { .mock(email: $0) },
        shareButtonModelFactory: .init { .mock(items: $0, userGroupIds: $1, userEmails: $2) },
        sharingService: SharingServiceMock()
      )
    )

  }
  .previewDisplayName("Admin Permission")
}

#Preview {
  NavigationView {
    SharingMembersDetailView(
      model: .init(
        members: .init(
          itemGroupInfo: .mock(),
          users: .users,
          userGroupMembers: .userGroups,
          collectionMembers: .collections
        ),
        item: PersonalDataMock.Credentials.sharedLimitedPermissionCredential,
        session: .mock,
        personalDataBD: ApplicationDBStack.mock(),
        gravatarViewModelFactory: .init { .mock(email: $0) },
        shareButtonModelFactory: .init { .mock(items: $0, userGroupIds: $1, userEmails: $2) },
        sharingService: SharingServiceMock()
      )
    )
  }
  .previewDisplayName("Limited Permission")
}

extension [User<ItemGroup>] {
  fileprivate static let users: Self = [
    .mock(id: "_"),
    .mock(id: "_", status: .pending),
    .mock(id: "_", permission: .limited),
  ]
}

extension [UserGroupMember<ItemGroup>] {
  fileprivate static let userGroups: Self = [.mock(name: "A Group"), .mock(name: "A Second Group")]
}

extension [CollectionMember] {
  fileprivate static let collections: Self = [
    .mock(name: "A Collection"), .mock(name: "A Second Collection"),
  ]
}
