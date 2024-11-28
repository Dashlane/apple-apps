import CorePersonalData
import CoreSharing
import DashTypes
import SwiftUI
import UIComponents
import VaultKit

struct SharingItemsUserDetailView: View {
  @StateObject
  var model: SharingItemsUserDetailViewModel

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

  init(model: @escaping @autoclosure () -> SharingItemsUserDetailViewModel) {
    self._model = .init(wrappedValue: model())
  }

  var body: some View {
    ZStack(alignment: .top) {
      DetailList(offsetEnabled: true, titleHeight: $titleHeight) {
        items
      }
      NavigationBar(
        leading: leadingButton,
        title: title,
        titleAccessory: iconView,
        trailing: EmptyView(),
        height: titleHeight)

    }
    .alert(item: $model.alertMessage) { message in
      Alert(title: Text(message))
    }
    .navigationBarHidden(true)
    .reportPageAppearance(.sharingMemberDetails)
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
    Text(model.user.id)
      .lineLimit(1)
      .foregroundColor(.ds.text.neutral.catchy)
  }

  var iconView: some View {
    GravatarIconView(
      model: model.gravatarIconViewModelFactory.make(email: model.user.id),
      isLarge: true
    )
    .environment(\.dynamicTypeSize, .xSmall)
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
  func actions(for item: SharedVaultItemInfo<User<ItemGroup>>) -> some View {
    if item.recipient.status == .pending {
      Button(L10n.Localizable.kwResendGroupInvite) {
        model.resendInvite(for: item)
      }
    }

    RevokeSharingButton()

    if item.recipient.status == .accepted {
      ChangeSharingPermissionButton(currentPermission: item.recipient.permission) { permission in
        model.changePermission(for: item, to: permission)
      }
    }
  }
}

#Preview {
  SharingItemsUserDetailView(
    model: .mock(
      user: .init(id: "_", items: [.mock(id: "1"), .mock(id: "2")]),
      item: Credential(),
      itemsProvider: .mock(
        vaultItemByIds: [
          "1": PersonalDataMock.Credentials.sharedAdminPermissionCredential,
          "2": PersonalDataMock.Credentials.sharedLimitedPermissionCredential,
        ]
      )
    )
  )
}
