import SwiftUI
import UIDelight
import DesignSystem
import SwiftTreats

extension View {

                @available(*, deprecated, message: "Use newLoginAppearance and remove usage of KeyboardSpacer")
    public func loginAppearance(backgroundColor: SwiftUI.Color? = nil) -> some View {
        modifier(
            LoginViewStyle(
                backgroundColor: backgroundColor ?? .ds.background.alternate,
                ignoreKeyboardSafeArea: true
            )
        )
    }
    
        public func newLoginAppearance(backgroundColor: SwiftUI.Color? = nil) -> some View {
        modifier(
            LoginViewStyle(
                backgroundColor: backgroundColor ?? .ds.background.alternate,
                ignoreKeyboardSafeArea: false
            )
        )
    }
}

struct LoginViewStyle: ViewModifier {
    let backgroundColor: SwiftUI.Color
    let ignoreKeyboardSafeArea: Bool

    func body(content: Content) -> some View {
        content
            .frame(maxWidth: Device.isIpadOrMac ? 550: nil, maxHeight:  Device.isIpadOrMac ? 890: nil) 
            .ignoresSafeArea(
                ignoreKeyboardSafeArea ? .keyboard : [],
                edges: ignoreKeyboardSafeArea ? .bottom : []
            )
            .backgroundColorIgnoringSafeArea(backgroundColor)
    }
}
