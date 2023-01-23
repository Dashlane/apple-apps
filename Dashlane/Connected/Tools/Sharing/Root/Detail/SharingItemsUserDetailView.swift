import SwiftUI
import CoreSharing
import VaultKit
import DashTypes
import UIComponents

struct SharingItemsUserDetailView: View {
    @StateObject
    var model: SharingItemsUserDetailViewModel

    @Environment(\.dismiss)
    var dismiss

    @State
    var showActionDialog: Bool = true

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
        .reportPageAppearance(.sharingMemberDetails)
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
        GravatarIconView(model: model.gravatarIconViewModelFactory.make(email: model.user.id), isLarge: true)
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
    func actions(for item: SharedVaultItemInfo<User>) -> some View {
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

 struct SharingItemsUserDetailView_Previews: PreviewProvider {
    static var previews: some View {
        SharingItemsUserDetailView(model: .mock(user: .init(id: "_", items: [.mock(id: "1"), .mock(id: "2")]), itemsProvider: .mock(vaultItemByIds: [
            "1": PersonalDataMock.Credentials.sharedAdminPermissionCredential,
            "2": PersonalDataMock.Credentials.sharedLimitedPermissionCredential
        ])))
    }
 }
