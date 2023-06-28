import Foundation

public extension String {

    func removeWhitespacesCharacters() -> String {
        return removeCharacters(from: .whitespacesAndNewlines)
    }

    private func removeCharacters(from forbiddenChars: CharacterSet) -> String {
        let passed = self.unicodeScalars.filter { !forbiddenChars.contains($0) }
        return String(String.UnicodeScalarView(passed))
    }
}
