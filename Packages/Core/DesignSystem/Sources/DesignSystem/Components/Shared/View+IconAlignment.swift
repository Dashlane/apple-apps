import SwiftUI

public enum IconAlignment {
    case leading
    case trailing
}

struct IconAlignmentKey: EnvironmentKey {
    static let defaultValue = IconAlignment.leading
}

extension EnvironmentValues {
    var iconAlignment: IconAlignment {
        get { self[IconAlignmentKey.self] }
        set { self[IconAlignmentKey.self] = newValue }
    }
}

public extension View {
            func iconAlignment(_ alignment: IconAlignment) -> some View {
        environment(\.iconAlignment, alignment)
    }
}
