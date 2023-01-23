import Foundation
import SwiftUI

#if os(iOS)

public extension View {

        @ViewBuilder
    func hideBottomBar(hidden: Bool) -> some View {
        if #available(iOS 16.0, *) {
#if !targetEnvironment(macCatalyst)
            self
                .toolbar(hidden ? .hidden : .visible, for: .bottomBar)
#else
            self
#endif
        } else {
            self
        }
    }
}
#endif
