#if os(iOS)
import Foundation
import SwiftUI

private struct ScrollContentBackgroundHiddenModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content
                .scrollContentBackground(.hidden)
        } else {
            content
        }
    }
}

extension View {
    public func scrollContentBackgroundHidden() -> some View {
        modifier(ScrollContentBackgroundHiddenModifier())
    }
}
#endif
