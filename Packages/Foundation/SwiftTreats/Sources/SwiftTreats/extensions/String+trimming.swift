import Foundation

public extension String {
    func stringWithFirstAndLastCharacterRemoved() -> String {
        guard count > 1 else {
            return ""
        }
        let from = self.index(after: self.startIndex)
        let to = self.index(before: self.endIndex)
        let range = Range(uncheckedBounds: (lower: from, upper: to))
        return String(self[range])
    }
    
    func trimCurlyBraces() -> String {
        guard first == "{" else {
            return self
        }
        return stringWithFirstAndLastCharacterRemoved()
    }
}

