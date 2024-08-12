import Foundation

struct CharactersSet {
  static let lowerLetter = Set(Array("abcdefghijklmnopqrstuvwxyz"))
  static let upperLetter = Set(Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ"))
  static let symbols = Set(Array("_"))
  static let numerals = Set(Array("1234567890"))

  struct Distinguishable {

    static let lowerLetter = Set(Array("abcdefghijkmnopqrstxyz"))
    static let upperLetter = Set(Array("ABCDEFGHJKLMNPQRSTXY"))

    static let numerals = Set("3456789")

  }
}
