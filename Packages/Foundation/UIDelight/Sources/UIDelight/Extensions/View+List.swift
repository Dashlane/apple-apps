import SwiftUI

public extension View {
    @ViewBuilder
    func disableHeaderCapitalization() -> some View {
        self.textCase(nil)
    }
}
