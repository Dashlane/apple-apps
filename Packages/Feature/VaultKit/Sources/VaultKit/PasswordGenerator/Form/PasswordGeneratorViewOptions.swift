import Combine
import CoreLocalization
import CorePasswords
import CoreSettings
import Foundation
import SwiftUI

public struct PasswordGeneratorViewOptions: View {

  @Binding
  var preferences: PasswordGeneratorPreferences

  public init(preferences: Binding<PasswordGeneratorPreferences>) {
    self._preferences = preferences
  }

  public var body: some View {
    VStack(alignment: .leading, spacing: 3) {
      Group {
        Toggle(isOn: $preferences.shouldContainDigits) {
          L10n.Core.kwPadExtensionGeneratorDigits
            .passwordColored(text: L10n.Core.kwPadExtensionGeneratorDigitsExample)
            .tracking(-0.41)
        }
        .fiberAccessibilityLabel(Text(L10n.Core.kwPadExtensionGeneratorDigitsAccessibility))
        Toggle(isOn: $preferences.shouldContainLetters) {
          L10n.Core.kwPadExtensionGeneratorLetters
            .passwordColored(text: L10n.Core.kwPadExtensionGeneratorLettersExample)
            .tracking(-0.41)
        }
        .fiberAccessibilityLabel(Text(L10n.Core.kwPadExtensionGeneratorLettersAccessibility))
        Toggle(isOn: $preferences.shouldContainSymbols) {
          L10n.Core.kwPadExtensionGeneratorSymbols
            .passwordColored(text: L10n.Core.kwPadExtensionGeneratorSymbolsExample)
            .tracking(-0.41)
        }
        .fiberAccessibilityLabel(Text(L10n.Core.kwPadExtensionGeneratorSymbolsAccessibility))
        Toggle(isOn: $preferences.allowSimilarCharacters) {
          L10n.Core.kwPadExtensionGeneratorSimilar
            .passwordColored(text: L10n.Core.kwPadExtensionGeneratorSimilarExample)
            .tracking(-0.41)
        }
        .fiberAccessibilityLabel(Text(L10n.Core.kwPadExtensionGeneratorSimilarAccessibility))
      }.padding(.vertical, 5)

    }
    .lineLimit(1)
    .minimumScaleFactor(0.6)
  }
}

struct PasswordGeneratorViewOptions_Previews: PreviewProvider {
  static var previews: some View {
    PasswordGeneratorViewOptions(preferences: Binding.constant(PasswordGeneratorPreferences()))
  }
}
