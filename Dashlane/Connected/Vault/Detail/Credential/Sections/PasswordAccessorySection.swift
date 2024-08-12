import CoreFeature
import CorePersonalData
import DesignSystem
import SwiftUI
import UIDelight

struct PasswordAccessorySection: View {
  @StateObject var model: PasswordAccessorySectionModel

  @FeatureState(.prideColors) private var isPrideColorsEnabled: Bool

  @Binding var showPasswordGenerator: Bool

  init(
    model: @escaping @autoclosure () -> PasswordAccessorySectionModel,
    showPasswordGenerator: Binding<Bool>
  ) {
    self._model = .init(wrappedValue: model())
    self._showPasswordGenerator = showPasswordGenerator
  }

  var body: some View {
    TextInputPasswordStrengthFeedback(
      strength: model.passwordStrength, colorful: isPrideColorsEnabled
    )
    .animation(.default, value: model.passwordStrength)
  }
}
