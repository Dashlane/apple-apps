import Combine
import CoreLocalization
import CorePasswords
import CoreSettings
import DesignSystem
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
          CoreL10n.kwPadExtensionGeneratorDigits
            .passwordColored(text: CoreL10n.kwPadExtensionGeneratorDigitsExample)
            .tracking(-0.41)
        }
        .fiberAccessibilityLabel(Text(CoreL10n.kwPadExtensionGeneratorDigitsAccessibility))
        Toggle(isOn: $preferences.shouldContainLetters) {
          CoreL10n.kwPadExtensionGeneratorLetters
            .passwordColored(text: CoreL10n.kwPadExtensionGeneratorLettersExample)
            .tracking(-0.41)
        }
        .fiberAccessibilityLabel(Text(CoreL10n.kwPadExtensionGeneratorLettersAccessibility))
        Toggle(isOn: $preferences.shouldContainSymbols) {
          CoreL10n.kwPadExtensionGeneratorSymbols
            .passwordColored(text: CoreL10n.kwPadExtensionGeneratorSymbolsExample)
            .tracking(-0.41)
        }
        .fiberAccessibilityLabel(Text(CoreL10n.kwPadExtensionGeneratorSymbolsAccessibility))
        Toggle(isOn: $preferences.allowSimilarCharacters) {
          CoreL10n.kwPadExtensionGeneratorSimilar
            .passwordColored(text: CoreL10n.kwPadExtensionGeneratorSimilarExample)
            .tracking(-0.41)
        }
        .fiberAccessibilityLabel(Text(CoreL10n.kwPadExtensionGeneratorSimilarAccessibility))
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

extension String {

  fileprivate func passwordColored(text: String) -> Text {
    guard let textRange = self.range(of: text) else {
      return Text(self)
    }
    let beginning = String(self[self.startIndex..<textRange.lowerBound])
    let end = String(self[textRange.upperBound..<self.endIndex])
    let colored = text.reduce(Text(beginning).foregroundStyle(Color.ds.text.neutral.standard)) {
      result, character in
      let coloredCharacter = Text("\(String(character))")
        .foregroundStyle(Color(passwordCharacter: character))
      return result + coloredCharacter
    }
    return colored + Text(end).foregroundStyle(Color.ds.text.neutral.standard)
  }
}
