import Combine
import CoreLocalization
import CorePersonalData
import DesignSystem
import SwiftUI
import UIComponents

private struct ActionableFieldModifier: ViewModifier {
  let title: String
  let isHidden: Bool
  let action: () -> Void

  @Environment(\.detailMode)
  var detailMode

  func body(content: Content) -> some View {
    HStack(alignment: .center, spacing: 4) {
      content
      if detailMode == .viewing && !isHidden {
        Spacer()
        Button(action: action, title: title)
          .accentColor(.ds.text.brand.standard)
      }
    }
  }
}

extension TextDetailField {
  public func openAction(didOpen: (() -> Void)? = nil) -> some View {
    self.modifier(
      ActionableFieldModifier(
        title: L10n.Core.kwOpen,
        isHidden: text.isEmpty,
        action: {
          if let url = PersonalDataURL(rawValue: self.text).openableURL {
            didOpen?()
            DispatchQueue.main.async {
              #if !EXTENSION
                UIApplication.shared.open(url)
              #endif
            }
          }
        }))
  }
}

extension View {
  public func action(
    _ title: String,
    isHidden: Bool = false,
    action: @escaping () -> Void
  ) -> some View {
    return modifier(ActionableFieldModifier(title: title, isHidden: isHidden, action: action))
  }

}

extension SecureDetailField {
  @ViewBuilder
  func copyAction(canCopy: Bool, copyAction: @escaping (String) -> Void) -> some View {
    if !canCopy {
      self
    } else {
      self.modifier(
        ActionableFieldModifier(
          title: L10n.Core.kwCopyButton,
          isHidden: copiableValue.wrappedValue.isEmpty,
          action: {
            copyAction(self.copiableValue.wrappedValue)
          }))
    }
  }
}
