import SwiftUI
import CoreSharing
import VaultKit
import DashTypes
import CorePersonalData
import UIComponents

struct SharingMembersDetailView: View {
    @StateObject
    var model: SharingMembersDetailViewModel

    var body: some View {
        List {
            if !model.members.userGroupMembers.isEmpty {
                userGroupsList
            }
            if !model.members.users.isEmpty {
                usersList
            }
        }
        .listStyle(.insetGrouped)
        .toolbar { toolbarContent }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(L10n.Localizable.tabContactsTitle)
        .navigationBarStyle(.alternate)
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
        if model.isSharingReady {
            ShareButton(model: model.makeShareButtonModelFactory()) {
                Image(asset: FiberAsset.add)
            }
        } else {
            Spacer()
        }
    }

        var userGroupsList: some View {
        LargeHeaderSection(title: L10n.Localizable.kwSharingCenterSectionGroups) {
            ForEach(model.members.userGroupMembers) { userGroup in
                HStack {
                    let isAdmin = model.permission == .admin
                    SharingToolRecipientRow(title: userGroup.name, subtitle: userGroup.localizedStatus) {
                        UserGroupIcon()
                    }.contextMenu {
                        if isAdmin {
                            userGroupMenuContent(for: userGroup)
                        }
                    }
                    if isAdmin {
                        let isInProgress = model.groupActionInProgressIds.contains(userGroup.id)
                        Menu {
                            userGroupMenuContent(for: userGroup)
                        } label: {
                            SharingEditLabel(isInProgress: isInProgress)
                        }.disabled(isInProgress)
                    }
                }.onRevokeSharing {
                    model.revoke(userGroup)
                }
            }
        }
    }

    @ViewBuilder
    func userGroupMenuContent(for userGroup: UserGroupMember) -> some View {
        RevokeSharingButton()

        ChangeSharingPermissionButton(currentPermission: userGroup.permission) { permission in
            model.changePermission(for: userGroup, to: permission)
        }
    }

    var usersList: some View {
        LargeHeaderSection(title: L10n.Localizable.kwSharingCenterSectionIndividuals) {
            ForEach(model.members.users) { user in
                HStack {
                    let shouldShowMenu = model.permission == .admin && user.id != model.currentUserId
                    SharingToolRecipientRow(title: user.id, subtitle: user.localizedStatus) {
                        GravatarIconView(model: model.gravatarViewModelFactory.make(email: user.id))
                    }.contextMenu {
                        if shouldShowMenu {
                            userMenuContent(for: user)
                        }
                    }

                    if shouldShowMenu {
                        let isInProgress = model.userActionInProgressIds.contains(user.id)
                        Menu {
                            userMenuContent(for: user)
                        } label: {
                            SharingEditLabel(isInProgress: isInProgress)
                        }.disabled(isInProgress)
                    }
                }.onRevokeSharing {
                    model.revoke(user)
                }
            }
        }
    }

    @ViewBuilder
    func userMenuContent(for user: User) -> some View {
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

struct SharingMembersDetailView_Previews: PreviewProvider {
    static let users: [User] = [.mock(id: "_"), .mock(id: "_", status: .pending), .mock(id: "_", permission: .limited)]
    static let userGroups: [UserGroupMember] = [.mock(name: "A Group"), .mock(name: "A Second Group")]
    static let members = ItemSharingMembers(itemGroupInfo: .mock(), users: users, userGroupMembers: userGroups)

    static var previews: some View {
        NavigationView {
            SharingMembersDetailView(model: .init(members: .init(itemGroupInfo: .mock(), users: users, userGroupMembers: userGroups),
                                                  item: PersonalDataMock.Credentials.sharedAdminPermissionCredential,
                                                  session: .mock,
                                                  personalDataBD: ApplicationDBStack.mock(),
                                                  gravatarViewModelFactory: .init { .mock(email: $0) },
                                                  shareButtonModelFactory: .init { .mock(items: $0, userGroupIds: $1, userEmails: $2) },
                                                  sharingService: SharingServiceMock()))

        }
        .previewDisplayName("Admin Permission")

        NavigationView {
            SharingMembersDetailView(model: .init(members: .init(itemGroupInfo: .mock(), users: users, userGroupMembers: userGroups),
                                                  item: PersonalDataMock.Credentials.sharedLimitedPermissionCredential,
                                                  session: .mock,
                                                  personalDataBD: ApplicationDBStack.mock(),
                                                  gravatarViewModelFactory: .init { .mock(email: $0) },
                                                  shareButtonModelFactory: .init { .mock(items: $0, userGroupIds: $1, userEmails: $2) },
                                                  sharingService: SharingServiceMock()))
        }
        .previewDisplayName("Limited Permission")

    }
}
