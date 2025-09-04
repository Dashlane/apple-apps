import SwiftUI

struct OnLoginUnlockAnimationModifier: ViewModifier {
  let onLoginLockPlaceholder: Image
  @State var locked: Bool = true

  func body(content: Content) -> some View {
    content
      .lockCover(isPresented: locked) {
        onLoginLockPlaceholder
          .edgesIgnoringSafeArea(.all)
      }
      .onAppear {
        locked = false
      }
  }
}
