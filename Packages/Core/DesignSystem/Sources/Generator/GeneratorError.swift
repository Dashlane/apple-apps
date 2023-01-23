import Foundation

enum GeneratorError: Error, CustomStringConvertible {
    case macOS12Required
    
    var description: String {
        switch self {
        case .macOS12Required:
            return "macOS 12 or above is required for this script to run"
        }
    }
}
