import SwiftUI

public enum TextFieldFeedbackAppearance {
    case error
}

enum TextFieldFeedbackAppearanceKey: EnvironmentKey {
    static let defaultValue: TextFieldFeedbackAppearance? = nil
}

extension EnvironmentValues {
    var textFieldFeedbackAppearance: TextFieldFeedbackAppearance? {
        get { self[TextFieldFeedbackAppearanceKey.self] }
        set { self[TextFieldFeedbackAppearanceKey.self] = newValue }
    }
}

public extension View {
                func textFieldFeedbackAppearance(_ appearance: TextFieldFeedbackAppearance?) -> some View {
        environment(\.textFieldFeedbackAppearance, appearance)
    }
}
