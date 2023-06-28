import SwiftUI

enum EditionDisabledKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    var editionDisabled: Bool {
        get { self[EditionDisabledKey.self] }
        set { self[EditionDisabledKey.self] = newValue }
    }
}

public extension View {
            func editionDisabled(_ disabled: Bool = true) -> some View {
        environment(\.editionDisabled, disabled)
    }
}
