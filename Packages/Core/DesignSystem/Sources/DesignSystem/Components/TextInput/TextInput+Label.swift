import SwiftUI

enum TextInputLabelKey: EnvironmentKey {
    static let defaultValue: String? = nil
}

extension EnvironmentValues {
    var textInputLabel: String? {
        get { self[TextInputLabelKey.self] }
        set { self[TextInputLabelKey.self] = newValue }
    }
}

public extension View {
    
            func textInputLabel(_ label: String) -> some View {
        environment(\.textInputLabel, label)
    }
}
