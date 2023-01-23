import Foundation

extension String {
    var boolValue: Bool {
        return (self as NSString).boolValue
    }

    func capitalizingFirstLetter() -> String {
        return prefix(1).uppercased() + dropFirst()
    }
}
