import Foundation

public struct PasswordCompositionOptions: OptionSet {
  public typealias RawValue = Int
  public let rawValue: Int

  public init(rawValue: Int) {
    self.rawValue = rawValue
  }

  public static let numerals = PasswordCompositionOptions(rawValue: 1 << 0)

  public static let lowerCaseLetters = PasswordCompositionOptions(rawValue: 1 << 1)
  public static let upperCaseLetters = PasswordCompositionOptions(rawValue: 1 << 2)

  public static let mixedLetters = [lowerCaseLetters, upperCaseLetters]

  public static let symbols = PasswordCompositionOptions(rawValue: 1 << 3)
  public static let all: PasswordCompositionOptions = [
    .numerals, .lowerCaseLetters, .upperCaseLetters, .symbols,
  ]

  static var allArray: [PasswordCompositionOptions] {
    return [.numerals, .lowerCaseLetters, .upperCaseLetters, .symbols]
  }
}

extension PasswordCompositionOptions {
  func characters(distinguishable: Bool) -> Set<Character> {
    switch (self, distinguishable) {
    case (.numerals, true):
      return CharactersSet.Distinguishable.numerals
    case (.numerals, false):
      return CharactersSet.numerals
    case (.lowerCaseLetters, true):
      return CharactersSet.Distinguishable.lowerLetter
    case (.lowerCaseLetters, false):
      return CharactersSet.lowerLetter
    case (.upperCaseLetters, true):
      return CharactersSet.Distinguishable.upperLetter
    case (.upperCaseLetters, false):
      return CharactersSet.upperLetter
    case (.symbols, _):
      return CharactersSet.symbols
    default:
      return []
    }
  }
  func allCharacterSets(distinguishable: Bool) -> [Set<Character>] {
    var characters = [Set<Character>]()
    for option in Self.allArray where self.contains(option) {
      characters.append(option.characters(distinguishable: distinguishable))
    }

    return characters
  }
}
