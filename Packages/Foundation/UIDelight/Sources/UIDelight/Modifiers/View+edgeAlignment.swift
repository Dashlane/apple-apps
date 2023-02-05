import SwiftUI

public extension View {
        func alignmentGuide(_ alignment: VerticalAlignment, to alignmentComputed: VerticalAlignment) -> some View {
        return self.alignmentGuide(alignment) {
            $0[alignmentComputed]
        }
    }
}
