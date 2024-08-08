import Foundation

extension Locale {
  public var isLatinBased: Bool {
    self.exemplarCharacterSet?.isSuperset(of: CharacterSet(charactersIn: "abc")) == true
  }
}
