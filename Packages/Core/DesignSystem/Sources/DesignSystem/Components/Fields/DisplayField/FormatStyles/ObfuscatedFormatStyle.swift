import CoreLocalization
import Foundation

struct ObfuscatedFormatStyle: AccessibleObfuscatedFormatStyle {
  let obfuscated: Bool
  let maxLength: Int?

  func format(_ value: String) -> String {
    obfuscated ? String(repeating: "•", count: maxLength ?? value.count) : value
  }

  func accessibilityText(for value: String) -> String {
    obfuscated ? CoreL10n.accessibilityHidden : value
  }
}

extension FormatStyle where Self == ObfuscatedFormatStyle {
  static func obfuscated(obfuscated: Bool, maxLength: Int?) -> ObfuscatedFormatStyle {
    ObfuscatedFormatStyle(obfuscated: obfuscated, maxLength: maxLength)
  }
}
