import CoreLocalization
import SwiftUI

public struct FieldCopyContentButton: View {
  private let action: @MainActor () -> Void

  public init(action: @escaping @MainActor () -> Void) {
    self.action = action
  }

  public var body: some View {
    DS.FieldAction.Button(L10n.Core.kwCopy, image: .ds.action.copy.outlined, action: action)
  }
}

#Preview {
  FieldActionsStack {
    FieldCopyContentButton {
      print("FieldCopyContentButton action triggered.")
    }
  }
}
