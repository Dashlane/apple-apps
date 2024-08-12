import Foundation

extension AttributedString {
  static func highlightedValue(_ value: String?, in string: String) -> AttributedString? {
    guard let value, string.localizedCaseInsensitiveContains(value)
    else { return nil }

    var attributedString = AttributedString(string)
    if let range = attributedString.range(
      of: value,
      options: [.caseInsensitive, .diacriticInsensitive]
    ) {
      attributedString[range].foregroundColor = .ds.text.brand.standard
      attributedString[range].backgroundColor = .ds.container.expressive.brand.quiet.idle
    }
    return attributedString
  }
}
