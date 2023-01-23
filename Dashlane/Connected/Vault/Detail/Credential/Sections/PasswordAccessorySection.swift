import CorePersonalData
import DesignSystem
import SwiftUI
import UIDelight

struct PasswordAccessorySection: View {

    @ObservedObject
    var model: PasswordAccessorySectionModel

    @Binding
    var showPasswordGenerator: Bool

    var body: some View {
        ZStack {
            if model.item.password.isEmpty {
                Button(L10n.Localizable.kwGenerate) {
                    self.showPasswordGenerator = true
                }
                .accentColor(.ds.text.brand.standard)
                .padding(7)
                .fiberAccessibilityHint(Text(L10n.Localizable.detailItemViewAccessibilityGenerateHint))
            } else {
                PasswordStrengthDetailField(passwordStrength: model.passwordStrength)
                    .animation(.default, value: model.passwordStrength)
            }
        }
        .frame(maxWidth: .infinity)
        .animation(.default, value: model.item.password.isEmpty)
    }
}
