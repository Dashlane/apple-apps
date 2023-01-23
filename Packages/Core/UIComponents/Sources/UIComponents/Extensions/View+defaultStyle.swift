import DesignSystem
import SwiftUI

public extension View {
    #if !targetEnvironment(macCatalyst)
    func dashlaneDefaultStyle() -> some View {
        self
    }
    #else
    func dashlaneDefaultStyle() -> some View {
        self
            .buttonStyle(ColoredButtonStyle(color: .ds.text.brand.standard))
            .toggleStyle(SwitchToggleStyle(tint: Color(asset: FiberAsset.switchDefaultTint)))
    }
    #endif
}
