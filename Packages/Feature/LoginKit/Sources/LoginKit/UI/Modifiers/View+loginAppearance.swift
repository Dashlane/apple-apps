import SwiftUI
import UIDelight
import DesignSystem

extension View {

                public func loginAppearance() -> some View {
        modifier(LoginViewStyle())
    }
}

struct LoginViewStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: 550, maxHeight: 890) 
            .ignoresSafeArea(.keyboard, edges: .bottom)
            .backgroundColorIgnoringSafeArea(.ds.background.default)
    }
}
