import Foundation

extension Error {
    public var debugDescription: String {
        [String(describing: self), localizedDescription].joined(separator: ";\n")
    }
}
