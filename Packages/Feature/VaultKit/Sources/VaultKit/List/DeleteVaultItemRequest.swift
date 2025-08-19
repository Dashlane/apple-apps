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
            Button(CoreL10n.kwYes, role: .destructive) {
              deleteAction()
            }
          } else {
            Button(CoreL10n.kwButtonOk) {}
          }
        },
        message: {
          if let message = request.itemDeleteBehavior.alertMessage {
            Text(message)
              .foregroundStyle(Color.ds.text.neutral.standard)
          }
        })
  }
}

extension ItemDeleteBehaviour {
  fileprivate var alertTitle: String {
    switch self {
    case .normal:
      return CoreL10n.kwDeleteConfirm
    case .canDeleteByLeavingItemGroup:
      return CoreL10n.kwDeleteConfirmAutoGroupTitle
    case .cannotDeleteWhenNoOtherAdmin:
      return CoreL10n.kwDeleteConfirmOnlyAdminMsg
    case .cannotDeleteUserInvolvedInUserGroup:
      return CoreL10n.kwDeleteConfirmGroup
    case .cannotDeleteItemInCollection:
      return CoreL10n.KWVaultItem.Sharing.Deletion.Error.message
    }
  }

  fileprivate var alertMessage: String? {
    switch self {
    case .canDeleteByLeavingItemGroup:
      return CoreL10n.kwDeleteConfirmAutoGroup
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
