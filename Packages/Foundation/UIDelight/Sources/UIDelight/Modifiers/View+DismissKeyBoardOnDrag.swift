import SwiftUI

#if !os(macOS)
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


public extension View {
    func dismissKeyboardOnDrag() -> some View {
        self.modifier(DismissKeyBoardOnDragModifier())
    }
}
#endif
