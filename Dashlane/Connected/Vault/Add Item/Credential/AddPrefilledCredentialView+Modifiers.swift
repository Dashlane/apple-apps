import SwiftUI
import VaultKit

private struct PrefilledCredentialViewSpecificBackButtonKey: EnvironmentKey {
    static var defaultValue: SpecificBackButton?
}

extension EnvironmentValues {
    var prefilledCredentialViewSpecificBackButton: SpecificBackButton? {
        get { self[PrefilledCredentialViewSpecificBackButtonKey.self] }
        set { self[PrefilledCredentialViewSpecificBackButtonKey.self] = newValue }
    }
}

extension View {
            func addPrefilledCredentialViewSpecificBackButton(_ type: SpecificBackButton) -> some View {
        self.environment(\.prefilledCredentialViewSpecificBackButton, type)
    }
}
