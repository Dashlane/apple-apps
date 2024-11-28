import CoreLocalization
import Foundation

struct IBANFormatStyle: AccessibleObfuscatedFormatStyle {
  let obfuscated: Bool

  func format(_ value: String) -> String {
    let chunks = chunks(for: value)

    if obfuscated {
      let obfuscatedPart = chunks.dropLast()
        .map { String(repeating: "•", count: $0.count) }
        .joined(separator: " ")
      let suffix = chunks.last

      return [obfuscatedPart, suffix].compactMap({ $0 }).joined(separator: " ")
    }

    return chunks.joined(separator: " ")
  }

  private func chunks(for value: String) -> [String] {
    let chunkLength = 4
    return value.split(by: chunkLength)
  }

  func accessibilityText(for value: String) -> String {
    if obfuscated {
      let suffix = chunks(for: value).last ?? ""
      return L10n.Core.accessibilityGenericNumberEndingWidth(value.count, suffix)
    }
    return value
  }
}

extension FormatStyle where Self == IBANFormatStyle {
  static func iban(obfuscated: Bool) -> IBANFormatStyle {
    IBANFormatStyle(obfuscated: obfuscated)
  }
}
