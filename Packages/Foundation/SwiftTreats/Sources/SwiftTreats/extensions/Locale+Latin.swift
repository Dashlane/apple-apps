import Foundation

public extension Locale {
    var isLatinBased: Bool {
        self.exemplarCharacterSet?.isSuperset(of: CharacterSet(charactersIn: "abc")) == true
    }
}
