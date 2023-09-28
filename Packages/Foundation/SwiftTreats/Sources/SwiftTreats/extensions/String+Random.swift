import Foundation

public extension String {
    static func randomAlphanumeric(ofLength length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyz0123456789"
        return String((0..<length).map { _ in letters.randomElement()! })
    }
}
