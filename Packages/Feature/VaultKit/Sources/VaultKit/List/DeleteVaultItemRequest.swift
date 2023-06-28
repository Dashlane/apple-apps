import SwiftUI
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
                return  Alert(title: Text(L10n.Core.kwDeleteConfirm),
                              primaryButton: .default(Text(L10n.Core.kwYes), action: deleteAction),
                              secondaryButton: .cancel(Text(L10n.Core.kwNo)))
            case .canDeleteByLeavingItemGroup:
                return Alert(title: Text(L10n.Core.kwDeleteConfirmAutoGroupTitle),
                             message: Text(L10n.Core.kwDeleteConfirmAutoGroup),
                             primaryButton: .default(Text(L10n.Core.kwYes), action: deleteAction),
                             secondaryButton: .cancel(Text(L10n.Core.kwNo)))
            case .cannotDeleteWhenNoOtherAdmin:
                return Alert(title: Text(L10n.Core.kwDeleteConfirmOnlyAdminMsg),
                             dismissButton: .cancel(Text(L10n.Core.kwButtonOk)))
            case .cannotDeleteUserInvolvedInUserGroup:
                return Alert(title: Text(L10n.Core.kwDeleteConfirmGroup),
                             dismissButton: .cancel(Text(L10n.Core.kwButtonOk)))
            }
        })
    }
}

public struct DeleteVaultItemRequest {
    public var isPresented: Bool = false
    public var itemDeleteBehavior: ItemDeleteBehaviour = .normal

    public init() { }
}

extension View {
    public func deleteItemAlert(request: Binding<DeleteVaultItemRequest>, deleteAction: @escaping () -> Void) -> some View {
        self.modifier(DeleteItemAlertModifier(request: request, deleteAction: deleteAction))
    }
}
