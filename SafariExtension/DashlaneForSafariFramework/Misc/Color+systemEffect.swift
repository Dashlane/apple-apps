import SwiftUI
import Cocoa

extension Color {
    func colorWithSystemEffect(_ effect: NSColor.SystemEffect) -> Color {
        return Color(NSColor(self).withSystemEffect(.pressed))
    }
}

