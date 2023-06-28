import SwiftUI

enum TextFieldLabelPersistencyDisabledKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    var textFieldLabelPersistencyDisabled: Bool {
        get { self[TextFieldLabelPersistencyDisabledKey.self] }
        set { self[TextFieldLabelPersistencyDisabledKey.self] = newValue }
    }
}

public extension View {
            func textFieldDisableLabelPersistency(_ disable: Bool = true) -> some View {
        environment(\.textFieldLabelPersistencyDisabled, disable)
    }
}
