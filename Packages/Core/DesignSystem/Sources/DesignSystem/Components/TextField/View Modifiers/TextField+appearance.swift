import SwiftUI

public enum TextFieldAppearance {
    case standalone
    case grouped
}

enum TextFieldAppearanceKey: EnvironmentKey {
    static let defaultValue = TextFieldAppearance.standalone
}

extension EnvironmentValues {
    var textFieldAppearance: TextFieldAppearance {
        get { self[TextFieldAppearanceKey.self] }
        set { self[TextFieldAppearanceKey.self] = newValue }
    }
}

public extension View {
                func textFieldAppearance(_ appearance: TextFieldAppearance) -> some View {
        environment(\.textFieldAppearance, appearance)
    }
}
