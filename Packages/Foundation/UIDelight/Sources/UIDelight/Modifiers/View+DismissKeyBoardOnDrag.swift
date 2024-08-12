#if canImport(UIKit)
  import SwiftUI
  import UIKit

  struct DismissKeyBoardOnDragModifier: ViewModifier {
    func body(content: Content) -> some View {
      content
        .onAppear {
          UIScrollView.appearance().keyboardDismissMode = .onDrag
        }.onDisappear {
          UIScrollView.appearance().keyboardDismissMode = .none
        }
    }
  }

  extension View {
    public func dismissKeyboardOnDrag() -> some View {
      self.modifier(DismissKeyBoardOnDragModifier())
    }
  }
#endif
