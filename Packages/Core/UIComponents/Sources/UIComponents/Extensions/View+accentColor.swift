#if targetEnvironment(macCatalyst)

import SwiftUI
import UIComponents

public extension View {
                    func accentColor(_ accentColor: SwiftUI.Color) -> some View {
        self.buttonStyle(ColoredButtonStyle(color: accentColor))
    }
 }

#endif
