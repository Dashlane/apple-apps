import SwiftUI
import UIComponents

extension View {
  func performOnShakeOrShortcut(_ action: @escaping () -> Void) -> some View {
    self
      .onShake {
        action()
      }
      .background {
        Button(
          action: {
            action()
          }, title: ""
        )
        .hidden()
        .keyboardShortcut("D", modifiers: [.shift, .command])
      }
  }
}
