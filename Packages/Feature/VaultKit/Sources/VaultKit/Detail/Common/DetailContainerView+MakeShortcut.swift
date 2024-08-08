import Foundation
import SwiftUI
import UIComponents

extension View {
  @ViewBuilder
  func makeShortcuts<Item: VaultItem & Equatable>(
    model: DetailContainerViewModel<Item>,
    edit: @escaping () -> Void,
    save: @escaping () -> Void,
    cancel: @escaping () -> Void,
    close: @escaping () -> Void,
    delete: @escaping () -> Void
  ) -> some View {
    self
      .mainMenuShortcut(
        .delete,
        enabled: model.mode == .updating,
        action: delete
      )
      .mainMenuShortcut(
        .save,
        enabled: model.mode.isEditing,
        action: save
      )
      .mainMenuShortcut(
        .cancel,
        enabled: model.mode.isEditing,
        action: cancel
      )
      .mainMenuShortcut(
        .edit,
        enabled: !model.mode.isEditing,
        action: edit
      )
      .mainMenuShortcut(
        .back,
        enabled: !model.mode.isEditing,
        action: close)
  }
}
