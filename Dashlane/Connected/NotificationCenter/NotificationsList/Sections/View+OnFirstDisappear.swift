import SwiftUI

private struct OnFirstDisappearModifier: ViewModifier {
  @State private var didDisappearOnce = false
  var onFirstDisappear: () -> Void

  func body(content: Content) -> some View {
    content
      .onDisappear {
        if !didDisappearOnce {
          didDisappearOnce = true
          onFirstDisappear()
        }
      }
  }
}

extension View {
  func onFirstDisappear(_ onFirstDisappear: @escaping () -> Void) -> some View {
    modifier(OnFirstDisappearModifier(onFirstDisappear: onFirstDisappear))
  }
}
