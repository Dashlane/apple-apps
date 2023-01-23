import SwiftUI
import UIComponents
import DesignSystem
import CoreLocalization

internal extension BackButton {
    init(color: Color = .ds.text.neutral.standard, action: @escaping () -> Void) {
        self.init(label: L10n.Core.kwBack, color: color,action: action)
    }
}
