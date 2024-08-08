import CoreLocalization
import CoreSharing
import SwiftUI

private struct DeleteItemAlertModifier: ViewModifier {
  @Binding
  var request: DeleteVaultItemRequest

  let deleteAction: () -> Void
  func body(content: Content) -> some View {
    content
      .alert(
        request.itemDeleteBehavior.alertTitle,
        isPresented: $request.isPresented,
        actions: {
          if request.itemDeleteBehavior.hasPrimaryButton {
            Button(L10n.Core.kwYes, role: .destructive, action: deleteAction)
          } else {
            Button(L10n.Core.kwButtonOk) {}
          }
        },
        message: {
          if let message = request.itemDeleteBehavior.alertMessage {
            Text(message)
          }
        })
  }
}

extension ItemDeleteBehaviour {
  fileprivate var alertTitle: String {
    switch self {
    case .normal:
      return L10n.Core.kwDeleteConfirm
    case .canDeleteByLeavingItemGroup:
      return L10n.Core.kwDeleteConfirmAutoGroupTitle
    case .cannotDeleteWhenNoOtherAdmin:
      return L10n.Core.kwDeleteConfirmOnlyAdminMsg
    case .cannotDeleteUserInvolvedInUserGroup:
      return L10n.Core.kwDeleteConfirmGroup
    case .cannotDeleteItemInCollection:
      return L10n.Core.KWVaultItem.Sharing.Deletion.Error.message
    }
  }

  fileprivate var alertMessage: String? {
    switch self {
    case .canDeleteByLeavingItemGroup:
      return L10n.Core.kwDeleteConfirmAutoGroup
    default:
      return nil
    }
  }

  fileprivate var hasPrimaryButton: Bool {
    switch self {
    case .canDeleteByLeavingItemGroup, .normal:
      return true
    default:
      return false
    }
  }
}

public struct DeleteVaultItemRequest {
  public var isPresented: Bool = false
  public var itemDeleteBehavior: ItemDeleteBehaviour = .normal

  public init() {}
}

extension View {
  public func deleteItemAlert(
    request: Binding<DeleteVaultItemRequest>, deleteAction: @escaping () -> Void
  ) -> some View {
    self.modifier(DeleteItemAlertModifier(request: request, deleteAction: deleteAction))
  }
}
