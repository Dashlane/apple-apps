import CoreSharing
import DashTypes
import DesignSystem
import SwiftUI
import UIComponents
import VaultKit

struct SharingItemsUserGroupDetailView: View {
  @StateObject
  var model: SharingItemsUserGroupDetailViewModel

  @Environment(\.dismiss)
  var dismiss

  @Environment(\.accessControl)
  var accessControl

  @State
  var showActionDialog: Bool = true

  @State
  var selectedItem: VaultItem?

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
      NavigationBar(
        leading: leadingButton,
        title: title,
        titleAccessory: titleAccessory,
        trailing: EmptyView(),
        height: titleHeight
      )

    }
    .alert(item: $model.alertMessage) { message in
      Alert(title: Text(message))
    }
    .navigationBarHidden(true)
    .reportPageAppearance(.sharingGroupItemList)
    .navigation(item: $selectedItem) { vaultItem in
      VaultDetailView(
        model: model.detailViewModelFactory.make(),
        itemDetailViewType: .viewing(vaultItem))
    }
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

  private var titleAccessory: some View {
    Thumbnail.User.group
      .controlSize(.large)
      .environment(\.dynamicTypeSize, .xSmall)
  }

  @ViewBuilder
  var usersRow: some View {
    if model.userGroup.isMember {
      NavigationLink(
        L10n.Localizable.userGroupMembersCountRowTitle(forCount: model.userGroup.users.count)
      ) {
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
      }
      .foregroundColor(.ds.text.neutral.catchy)
    } else {
      Text(L10n.Localizable.kwSharingUserGroupNotAMember)
        .foregroundColor(.ds.text.neutral.quiet)
    }
  }

  var items: some View {
    Section {
      ForEach(model.items) { item in
        SharedItemInfoRow(model: model.makeRowViewModel(item: item)) {
          accessControl.requestAccess(to: item.vaultItem) { success in
            guard success else {
              return
            }
            selectedItem = item.vaultItem
          }
        } menuActions: {
          actions(for: item)
            .disabled(item.recipient.parentGroupId != item.group.id)
        }.onRevokeSharing {
          model.revoke(item)
        }
      }
    }
  }

  @ViewBuilder
  func actions(for item: SharedVaultItemInfo<UserGroupMember<ItemGroup>>) -> some View {
    RevokeSharingButton()

    if item.recipient.status == .accepted {
      ChangeSharingPermissionButton(currentPermission: item.recipient.permission) { permission in
        model.changePermission(for: item, to: permission)
      }
    }
  }
}

#Preview("Current user is member") {
  SharingItemsUserGroupDetailView(
    model: .mock(
      userGroup: .init(
        id: Identifier(),
        name: "A group",
        isMember: true,
        items: [.mock(id: "1"), .mock(id: "2")],
        users: [.mock(), .mock()]
      ),
      itemsProvider: .mock(
        vaultItemByIds: [
          "1": PersonalDataMock.Credentials.sharedAdminPermissionCredential,
          "2": PersonalDataMock.Credentials.sharedLimitedPermissionCredential,
        ]
      )
    )
  )
}

#Preview("Current user is not a member") {
  SharingItemsUserGroupDetailView(
    model: .mock(
      userGroup: .init(
        id: Identifier(),
        name: "A group",
        isMember: false,
        items: [.mock(id: "1"), .mock(id: "2")],
        users: [.mock(), .mock()]
      ),
      itemsProvider: .mock(
        vaultItemByIds: [
          "1": PersonalDataMock.Credentials.sharedAdminPermissionCredential,
          "2": PersonalDataMock.Credentials.sharedLimitedPermissionCredential,
        ]
      )
    )
  )
}
