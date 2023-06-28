import SwiftUI

public enum TextFieldValueColorHighlightingMode {
    case password
    case url
}

enum TextFieldValueColorHighlightingModeKey: EnvironmentKey {
    static let defaultValue: TextFieldValueColorHighlightingMode? = nil
}

extension EnvironmentValues {
    var textFieldValueColorHighlightingMode: TextFieldValueColorHighlightingMode? {
        get { self[TextFieldValueColorHighlightingModeKey.self] }
        set { self[TextFieldValueColorHighlightingModeKey.self] = newValue }
    }
}

public extension View {
            func textFieldColorHighlightingMode(_ mode: TextFieldValueColorHighlightingMode?) -> some View {
        environment(\.textFieldValueColorHighlightingMode, mode)
    }
}
