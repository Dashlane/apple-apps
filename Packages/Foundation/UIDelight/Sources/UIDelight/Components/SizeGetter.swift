import SwiftUI
import Foundation

public extension View {
        func onSizeChange(_ changeHandler: @escaping (CGSize) -> Void) -> some View {
        return self
            .background(GeometryGetter(handler: changeHandler)) 
    }
}

private struct GeometryGetter: View {
    let handler: (CGSize) -> Void

    var body: some View {
        Rectangle()
            .foregroundColor(.clear)
            .background(reader)
            .onPreferenceChange(SizePreferenceKey.self, perform: handler)
    }

    var reader: some View {
        GeometryReader { geometry in
            return Rectangle()
                .foregroundColor(.clear)
                .preference(key: SizePreferenceKey.self, value: geometry.size)
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

private struct SizePreferenceKey: PreferenceKey {
    static var defaultValue = CGSize.zero

    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        value = nextValue()
    }
}
