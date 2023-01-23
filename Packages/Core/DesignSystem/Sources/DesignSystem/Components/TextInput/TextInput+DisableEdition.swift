import SwiftUI

enum TextInputDisableEditionKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    var textInputDisableEdition: Bool {
        get { self[TextInputDisableEditionKey.self] }
        set { self[TextInputDisableEditionKey.self] = newValue }
    }
}

public extension View {

                        func textInputDisableEdition() -> some View {
        environment(\.textInputDisableEdition, true)
    }
}
