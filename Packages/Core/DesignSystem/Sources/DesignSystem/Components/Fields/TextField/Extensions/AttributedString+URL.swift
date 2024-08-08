import SwiftUI

extension AttributedString {

  static func urlAttributedString(
    from url: String,
    dynamicTypeSize: DynamicTypeSize,
    mood: Mood
  ) -> AttributedString {
    var attributedString = AttributedString(url)
    attributedString.font = TextStyle.body.standard.regular.font(for: dynamicTypeSize)
    if mood == .danger {
      attributedString.foregroundColor = .ds.text.danger.standard
    } else {
      attributedString.foregroundColor = .ds.text.neutral.catchy
    }

    if let securePrefixRange = attributedString.range(of: "_") {
      attributedString[securePrefixRange].foregroundColor = .ds.text.neutral.quiet
    } else if let unsecurePrefixRange = attributedString.range(of: "_") {
      attributedString[unsecurePrefixRange].foregroundColor = .ds.text.neutral.quiet
    }
    return attributedString
  }
}
