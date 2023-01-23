import SwiftUI
import VaultKit
import CoreSharing
import CoreLocalization

private struct DeleteItemAlertModifier: ViewModifier {
    @Binding
    var request: DeleteVaultItemRequest

    let deleteAction: () -> Void
    func body(content: Content) -> some View {
        content.alert(isPresented: self.$request.isPresented, content: {
            switch request.itemDeleteBehavior {
            case .normal:
                return  Alert(title: Text(L10n.Localizable.kwDeleteConfirm),
                              primaryButton: .default(Text(L10n.Localizable.kwYes), action: deleteAction),
                              secondaryButton: .cancel(Text(L10n.Localizable.kwNo)))
            case .canDeleteByLeavingItemGroup:
                return Alert(title: Text(L10n.Localizable.kwDeleteConfirmAutoGroupTitle),
                             message: Text(L10n.Localizable.kwDeleteConfirmAutoGroup),
                             primaryButton: .default(Text(L10n.Localizable.kwYes), action: deleteAction),
                             secondaryButton: .cancel(Text(L10n.Localizable.kwNo)))
            case .cannotDeleteWhenNoOtherAdmin:
                return Alert(title: Text(L10n.Localizable.kwDeleteConfirmOnlyAdminMsg),
                             dismissButton: .cancel(Text(L10n.Localizable.kwButtonOk)))
            case .cannotDeleteUserInvolvedInUserGroup:
                return Alert(title: Text(L10n.Localizable.kwDeleteConfirmGroup),
                             dismissButton: .cancel(Text(L10n.Localizable.kwButtonOk)))
            }
        })
    }
}


struct DeleteVaultItemRequest {
    var isPresented: Bool = false
    var itemDeleteBehavior: ItemDeleteBehaviour = .normal
}

extension View {
    func deleteItemAlert(request: Binding<DeleteVaultItemRequest>, deleteAction: @escaping () -> Void) -> some View {
        self.modifier(DeleteItemAlertModifier(request: request, deleteAction: deleteAction))
    }
}
