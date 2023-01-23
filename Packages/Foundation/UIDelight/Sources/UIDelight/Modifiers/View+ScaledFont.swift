#if os(iOS)

import Foundation
import SwiftUI

struct ScaledFont: ViewModifier {
    
            @Environment(\.sizeCategory) var sizeCategory
    var size: CGFloat
    
    func body(content: Content) -> some View {
        let scaledSize = UIFontMetrics.default.scaledValue(for: size)
        return content.font(.system(size: scaledSize))
    }
}

public extension View {
    func scaledFont(size: CGFloat) -> some View {
        return self.modifier(ScaledFont(size: size))
    }
}

#endif
