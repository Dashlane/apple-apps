import CorePersonalData
import DesignSystem
import CoreFeature
import SwiftUI
import UIDelight

struct PasswordAccessorySection: View {

    @ObservedObject
    var model: PasswordAccessorySectionModel

    @FeatureState(.prideColors)
    private var isPrideColorsEnabled: Bool

    @Binding
    var showPasswordGenerator: Bool

    var body: some View {
        TextFieldPasswordStrengthFeedback(strength: model.passwordStrength, colorful: isPrideColorsEnabled)
            .animation(.default, value: model.passwordStrength)
    }
}
