import SwiftUI

enum TextInputIsSecureKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    var textInputIsSecure: Bool {
        get { self[TextInputIsSecureKey.self] }
        set { self[TextInputIsSecureKey.self] = newValue }
    }
}

public extension View {

                    func textInputIsSecure(_ isSecure: Bool) -> some View {
        environment(\.textInputIsSecure, isSecure)
    }
}
