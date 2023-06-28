import Foundation

public extension Sequence where Iterator.Element == URLQueryItem {
    subscript(name: String) -> String? {
        return self.first { $0.name == name }?.value
    }
}
