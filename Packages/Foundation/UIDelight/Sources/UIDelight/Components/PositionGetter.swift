import Foundation
import SwiftUI

public extension View {
        func onPositionChange(_ changeHandler: @escaping (CGRect) -> Void) -> some View {
        return self.background(GeometryGetter())
            .onPreferenceChange(PositionPreferenceKey.self, perform: changeHandler)
    }
}

private struct GeometryGetter: View {
    var body: some View {
        GeometryReader { geometry in
            Color.clear.preference(key: PositionPreferenceKey.self, value: geometry.frame(in: .global))
        }
    }
}

private struct PositionPreferenceKey: PreferenceKey {
    static var defaultValue = CGRect.zero

    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}
