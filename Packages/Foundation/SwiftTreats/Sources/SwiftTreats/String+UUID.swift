import Foundation

extension String {

    public func onlyAlphanumeric() -> String {
        return String(unicodeScalars.filter { scalar in
            CharacterSet.alphanumerics.contains(scalar)
        })
    }
}
