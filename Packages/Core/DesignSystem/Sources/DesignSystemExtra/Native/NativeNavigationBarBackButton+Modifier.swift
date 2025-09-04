import CoreLocalization
import SwiftUI

private struct Modifier: ViewModifier {
  let label: String?
  let action: () -> Void

  init(label: String?, action: @escaping () -> Void) {
    self.label = label
    self.action = action
  }

  func body(content: Content) -> some View {
    content
      .navigationBarBackButtonHidden()
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          NativeNavigationBarBackButton(label, action: action)
        }
      }
  }
}

extension View {
  public func navigationBarBackButton(
    _ label: String? = nil, action: @escaping @MainActor () -> Void
  ) -> some View {
    self.modifier(Modifier(label: label, action: action))
  }
}
