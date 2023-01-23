import SwiftUI
import CoreSharing
import VaultKit
import DashTypes
import UIComponents

struct SharingItemsUserGroupDetailView: View {
    @StateObject
    var model: SharingItemsUserGroupDetailViewModel

    @Environment(\.dismiss)
    var dismiss

    @State
    var showActionDialog: Bool = true

    @State
    var titleHeight: CGFloat? = DetailDimension.defaultNavigationBarHeight

    init(model: @escaping @autoclosure () -> SharingItemsUserGroupDetailViewModel) {
        self._model = .init(wrappedValue: model())
    }

    var body: some View {
        ZStack(alignment: .top) {
            DetailList(offsetEnabled: true, titleHeight: $titleHeight) {
                usersRow
                items
            }
            NavigationBar(leading: leadingButton,
                          title: title,
                          titleAccessory: iconView,
                          trailing: EmptyView(),
                          height: titleHeight)

        }
        .alert(item: $model.alertMessage) { message in
            Alert(title: Text(message))
        }
        .navigationBarHidden(true)
        .reportPageAppearance(.sharingGroupItemList)
    }

        var leadingButton: some View {
        BackButton(label: L10n.Localizable.tabContactsTitle, color: .ds.text.brand.standard) {
            dismiss()
        }
        .accentColor(.ds.text.brand.standard)
    }

    var title: some View {
        Text(model.userGroup.name)
            .lineLimit(1)
            .foregroundColor(.ds.text.neutral.catchy)
    }

    var iconView: some View {
        Image(asset: FiberAsset.userGroup)
            .contactsIconStyle(isLarge: true)
    }

        @ViewBuilder
    var usersRow: some View {
        if model.userGroup.isMember {
            NavigationLink(L10n.Localizable.userGroupMembersCountRowTitle(forCount: model.userGroup.users.count)) {
                List {
                    Section {
                        ForEach(model.userGroup.users) { user in
                            SharingToolRecipientRow(title: user.id, subtitle: user.localizedStatus) {
                                GravatarIconView(model: model.gravatarIconViewModelFactory.make(email: user.id))
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .navigationTitle(L10n.Localizable.kwSharingCenterSectionIndividuals)
                .navigationBarHidden(false)
                .reportPageAppearance(.sharingGroupMemberList)
            }.foregroundColor(.ds.text.neutral.catchy)
        } else {
            Text(L10n.Localizable.kwSharingUserGroupNotAMember)
                .foregroundColor(.ds.text.neutral.quiet)
        }
    }

        var items: some View {
        Section {
            ForEach(model.items) { item in
                SharedItemInfoRow(model: model.makeRowViewModel(item: item)) {
                    actions(for: item)
                }.onRevokeSharing {
                    model.revoke(item)
                }
            }
        }
    }

    @ViewBuilder
    func actions(for item: SharedVaultItemInfo<UserGroupMember>) -> some View {
        RevokeSharingButton()

        if item.recipient.status == .accepted {
            ChangeSharingPermissionButton(currentPermission: item.recipient.permission) { permission in
                model.changePermission(for: item, to: permission)
            }
        }
    }
}

struct SharingItemsUserGroupDetailView_Previews: PreviewProvider {
    static var previews: some View {
        SharingItemsUserGroupDetailView(model: .mock(userGroup: .init(id: Identifier(),
                                                                      name: "A group",
                                                                      isMember: true,
                                                                      items: [.mock(id: "1"), .mock(id: "2")],
                                                                      users: [.mock(), .mock()]), itemsProvider: .mock(vaultItemByIds: [
                                                                        "1": PersonalDataMock.Credentials.sharedAdminPermissionCredential,
                                                                        "2": PersonalDataMock.Credentials.sharedLimitedPermissionCredential
                                                                      ])))
        .previewDisplayName("Current user is member")

        SharingItemsUserGroupDetailView(model: .mock(userGroup: .init(id: Identifier(),
                                                                      name: "A group",
                                                                      isMember: false,
                                                                      items: [.mock(id: "1"), .mock(id: "2")],
                                                                      users: [.mock(), .mock()]), itemsProvider: .mock(vaultItemByIds: [
                                                                        "1": PersonalDataMock.Credentials.sharedAdminPermissionCredential,
                                                                        "2": PersonalDataMock.Credentials.sharedLimitedPermissionCredential
                                                                      ])))
        .previewDisplayName("Current user is not member")
    }
}
