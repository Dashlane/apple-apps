import Foundation
import SwiftUI

struct InfoboxButtonSectionConfiguration: EnvironmentKey {
    static var defaultValue: Infobox.ButtonSectionConfiguration = .secondaryAndPrimary
}

extension EnvironmentValues {
    var infoboxButtonSectionConfiguration: Infobox.ButtonSectionConfiguration {
        get { self[InfoboxButtonSectionConfiguration.self] }
        set { self[InfoboxButtonSectionConfiguration.self] = newValue }
    }
}

public extension Infobox {
    enum InfoboxButtonSectionStyle {
        case standaloneSecondaryButton
    }

    func infoboxButtonStyle(_ style: InfoboxButtonSectionStyle) -> some View {
        switch style {
        case .standaloneSecondaryButton:
            return self.environment(\.infoboxButtonSectionConfiguration, .standaloneSecondaryButton)
        }
    }
}
