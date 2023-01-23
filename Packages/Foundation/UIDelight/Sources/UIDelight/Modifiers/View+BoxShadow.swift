import SwiftUI

struct BoxShadowModifier: ViewModifier {
    let enabled: Bool
    
    func body(content: Content) -> some View {
        if enabled {
            content
                .shadow(color: Color.black.opacity(0.15), radius: 15, x: 0, y: 10)
                .shadow(color: Color.black.opacity(0.05), radius: 17, x: 0, y: 14)
        } else {
            content
        }
    }
}

extension View {
    @ViewBuilder
        public func boxShadow(enabled: Bool = true) -> some View {
        self.modifier(BoxShadowModifier(enabled: enabled))
    }
}
