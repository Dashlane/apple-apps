import Foundation

protocol AccessibleObfuscatedFormatStyle: FormatStyle {
  func accessibilityText(for value: FormatInput) -> FormatOutput
}
