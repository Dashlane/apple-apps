import SwiftUI

public extension View {
    func eraseToAnyView() -> AnyView {
        return AnyView(self)
    }
}
