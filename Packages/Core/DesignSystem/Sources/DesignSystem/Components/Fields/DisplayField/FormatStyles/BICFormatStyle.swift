import CoreLocalization
import Foundation

struct BICFormatStyle: AccessibleObfuscatedFormatStyle {
  let obfuscated: Bool

  func format(_ value: String) -> String {
    let chunks = chunks(for: value)

    if obfuscated {
      guard chunks.count > 1
      else { return String(repeating: "•", count: value.count) }

      let obfuscatedParts =
        chunks
        .dropLast()
        .map { String(repeating: "•", count: $0.count) }
        .joined(separator: " ")
      let suffix = chunks.last

      return [obfuscatedParts, suffix]
        .compactMap { $0 }
        .joined(separator: " ")
    }

    return chunks.joined(separator: " ")
  }

  private func chunks(for value: String) -> [String] {
    let chunks: [Int] =
      switch value.count {
      case 8:
        [4, 2, 2]
      case 11:
        [4, 2, 2, 3]
      case 12:
        [4, 2, 2, 1, 3]
      default:
        [value.count]
      }

    return value.split(byChunks: chunks)
  }

  func accessibilityText(for value: String) -> String {
    if obfuscated {
      let suffix = chunks(for: value).last ?? ""
      return L10n.Core.accessibilityGenericNumberEndingWidth(value.count, suffix)
    }
    return format(value)
  }
}

extension FormatStyle where Self == IBANFormatStyle {
  static func bic(obfuscated: Bool) -> BICFormatStyle {
    BICFormatStyle(obfuscated: obfuscated)
  }
}
