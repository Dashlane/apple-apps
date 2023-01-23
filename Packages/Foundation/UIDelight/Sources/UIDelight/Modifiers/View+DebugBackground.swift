import Foundation
import SwiftUI

public extension Color {
    static var random: Color {
        return Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1)
        )
    }
}

public extension View {

                func debugBackgroundColor() -> some View {
        self.background(Color.random)
    }
    
                func debugForegroundColor() -> some View {
        self.foregroundColor(Color.random)
    }
}
