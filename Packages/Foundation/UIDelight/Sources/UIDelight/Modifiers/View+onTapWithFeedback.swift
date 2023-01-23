import Foundation
import SwiftUI

public extension View {
        @ViewBuilder
    func onTapWithFeedback(perform action: @escaping () -> Void) -> some View {
        #if targetEnvironment(macCatalyst)
        Button(action: action, label: {
            self
                .contentShape(Rectangle())
        })
        .buttonStyle(DefaultButtonStyle())
        .foregroundColor(.primary)
        
        #else
        Button(action: action, label: {
            self
                .contentShape(Rectangle())
        }).foregroundColor(.primary)
        #endif
        
    }
}
