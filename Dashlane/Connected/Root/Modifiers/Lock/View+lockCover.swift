import SwiftTreats
import SwiftUI

extension View {
  func lockCover<Lock: View>(isPresented: Bool, @ViewBuilder lock: () -> Lock) -> some View {
    modifier(LockModifier(lockOverlay: lock(), locked: isPresented))
  }
}

struct LockModifier<Lock: View>: ViewModifier {
  let lockOverlay: Lock
  let locked: Bool

  func body(content: Content) -> some View {
    ZStack {
      if !Device.is(.mac, .pad) {
        Color.black
          .padding(.vertical, 20)
      }

      content
        .modifier(LockedContentModifier(locked: locked))

      if locked {
        lockOverlay
          .zIndex(100)
          .transition(.unlock)
      }
    }
    .animation(.easeIn(duration: 0.6), value: locked)
  }
}

private struct LockedContentModifier: ViewModifier, Animatable {
  let locked: Bool

  var scale: Double {
    Device.is(.mac, .pad) ? 1 : 0.9
  }

  func body(content: Content) -> some View {

    content
      .scaleEffect(locked ? scale : 1)
      .opacity(locked ? 0.5 : 1)
      .animation(.smooth(duration: 0.5), value: locked)
  }
}
