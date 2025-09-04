import SwiftUI

extension AttributedString {

  static func passwordAttributedString(
    from password: String,
    with dynamicTypeSize: DynamicTypeSize
  ) -> AttributedString {
    var attributedString = AttributedString(password)
    attributedString.font = TextStyle.body.standard.monospace.font(for: dynamicTypeSize)
    attributedString.foregroundColor = .ds.text.neutral.catchy

    let characters = attributedString.characters

    for characterIndice in characters.indices {
      let range = characterIndice..<characters.index(after: characterIndice)
      if let character = characters[range].first {
        attributedString[range].foregroundColor = Color(passwordCharacter: character)
      }
    }

    return attributedString
  }
}

extension Color {
  public init(passwordCharacter: Character) {
    switch passwordCharacter {
    case let passwordChar where passwordChar.isLetter:
      self = .ds.text.neutral.catchy
    case let passwordChar where passwordChar.isNumber:
      self = .ds.text.oddity.passwordDigits
    default:
      self = .ds.text.oddity.passwordSymbols
    }
  }
}
