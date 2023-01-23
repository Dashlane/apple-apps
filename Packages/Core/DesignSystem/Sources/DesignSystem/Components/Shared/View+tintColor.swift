import SwiftUI

struct TintColorKey: EnvironmentKey {
    static let defaultValue: Color? = nil
}

extension EnvironmentValues {
    var tintColor: Color? {
        get { self[TintColorKey.self] }
        set { self[TintColorKey.self] = newValue }
    }
}

#if targetEnvironment(macCatalyst)
extension View {
        func tintColor(_ color: Color) -> some View {
        environment(\.tintColor, color)
    }
}
#endif
