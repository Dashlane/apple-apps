import Foundation
import SwiftUI
import SwiftTreats

private struct Tappable: ViewModifier {
    
    let enabled: Bool
    let action: () -> ()
    
    @ViewBuilder
    func body(content: Content) -> some View {
        if Device.isIpadOrMac, !ProcessInfo.isTesting {
            Button(action: self.action) {
                content
            }
            .buttonStyle(UltraPlainButtonStyle())
            .disabled(!enabled)
        } else {
            content
                                .gesture(enabled ? TapGesture().onEnded(action) : nil)
        }
    }
}

private struct UltraPlainButtonStyle: ButtonStyle {
    public func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
    }
}

extension View {
    
            public func onTapGesture(perform action: @escaping () -> Void) -> some View {
        self.modifier(Tappable(enabled: true, action: action))
    }
    
                public func onTapGesture(enabled: Bool,
                             perform action: @escaping () -> Void) -> some View {
        self.modifier(Tappable(enabled: enabled, action: action))
    }
}
