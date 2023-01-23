
import Foundation

extension String {
    func isEmptyOrWhitespaces() -> Bool {
        return trimmingCharacters(in: .whitespaces).isEmpty
    }
}
