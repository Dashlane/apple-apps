import SwiftUI

public extension View {
        func backgroundColorIgnoringSafeArea(_ color: Color) -> some View {
        self.modifier(FullBackgroundColorModifier(color: color))
    }
}

private struct FullBackgroundColorModifier: ViewModifier {
    var color: Color

    func body(content: Content) -> some View {
        ZStack {
            color.edgesIgnoringSafeArea(.all)
            content
        }
    }
}

