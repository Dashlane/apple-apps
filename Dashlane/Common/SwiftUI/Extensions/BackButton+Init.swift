import SwiftUI
import UIComponents
import LoginKit
import DesignSystem

extension BackButton {
    public init(color: Color = .ds.text.neutral.standard, action: @escaping () -> Void) {
        self.init(label: L10n.Localizable.kwBack, color: color, action: action)
    }
}
