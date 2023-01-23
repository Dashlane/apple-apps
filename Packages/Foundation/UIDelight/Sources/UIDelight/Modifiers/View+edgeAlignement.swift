import SwiftUI

public extension View {
        func alignmentGuide(_ alignement: VerticalAlignment, to alignementComputed: VerticalAlignment) -> some View {
        return self.alignmentGuide(alignement) {
            $0[alignementComputed]
        }
    }
}
