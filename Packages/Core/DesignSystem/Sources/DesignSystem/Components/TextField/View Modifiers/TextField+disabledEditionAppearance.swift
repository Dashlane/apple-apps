import SwiftUI

public enum TextFieldDisabledEditionAppearance {
    case discrete
    case emphasized
}

enum TextFieldDisabledEditionAppearanceKey: EnvironmentKey {
    static let defaultValue = TextFieldDisabledEditionAppearance.emphasized
}

extension EnvironmentValues {
    var textFieldDisabledEditionAppearance: TextFieldDisabledEditionAppearance {
        get { self[TextFieldDisabledEditionAppearanceKey.self] }
        set { self[TextFieldDisabledEditionAppearanceKey.self] = newValue }
    }
}

public extension View {
    func textFieldDisabledEditionAppearance(_ mode: TextFieldDisabledEditionAppearance) -> some View {
        environment(\.textFieldDisabledEditionAppearance, mode)
    }
}
