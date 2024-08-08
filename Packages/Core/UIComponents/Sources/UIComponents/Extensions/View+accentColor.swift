#if targetEnvironment(macCatalyst)

  import SwiftUI
  import UIComponents

  extension View {
    public func accentColor(_ accentColor: SwiftUI.Color) -> some View {
      self.buttonStyle(ColoredButtonStyle(color: accentColor))
    }
  }

#endif
