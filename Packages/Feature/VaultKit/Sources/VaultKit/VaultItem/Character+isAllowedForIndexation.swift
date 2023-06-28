import Foundation

extension Character {
            var isAllowedForIndexation: Bool {
        guard isLetter,
              let scalar = Unicode.Scalar(String(self)),
              scalar.isASCII else {
            return false
        }
        return true
    }
}
