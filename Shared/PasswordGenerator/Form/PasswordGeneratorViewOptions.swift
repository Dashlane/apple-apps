import Foundation
import SwiftUI
import CorePasswords
import Combine
import DashlaneAppKit
import CoreSettings

struct PasswordGeneratorViewOptions: View {

    @Binding
    var preferences: PasswordGeneratorPreferences
    
    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Group {
                Toggle(isOn: $preferences.shouldContainDigits) {
                    L10n.Localizable.kwPadExtensionGeneratorDigits
                        .passwordColored(text: L10n.Localizable.kwPadExtensionGeneratorDigitsExample)
                        .tracking(-0.41)
                }
                .fiberAccessibilityLabel(Text(L10n.Localizable.kwPadExtensionGeneratorDigitsAccessibility))
                Toggle(isOn: $preferences.shouldContainLetters) {
                    L10n.Localizable.kwPadExtensionGeneratorLetters
                        .passwordColored(text: L10n.Localizable.kwPadExtensionGeneratorLettersExample)
                        .tracking(-0.41)
                }
                .fiberAccessibilityLabel(Text(L10n.Localizable.kwPadExtensionGeneratorLettersAccessibility))
                Toggle(isOn: $preferences.shouldContainSymbols) {
                    L10n.Localizable.kwPadExtensionGeneratorSymbols
                        .passwordColored(text: L10n.Localizable.kwPadExtensionGeneratorSymbolsExample)
                        .tracking(-0.41)
                }
                .fiberAccessibilityLabel(Text(L10n.Localizable.kwPadExtensionGeneratorSymbols))
                Toggle(isOn: $preferences.allowSimilarCharacters) {
                    L10n.Localizable.kwPadExtensionGeneratorSimilar
                        .passwordColored(text: L10n.Localizable.kwPadExtensionGeneratorSimilarExample)
                        .tracking(-0.41)
                }
                .fiberAccessibilityLabel(Text(L10n.Localizable.kwPadExtensionGeneratorSimilarAccessibility))
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
