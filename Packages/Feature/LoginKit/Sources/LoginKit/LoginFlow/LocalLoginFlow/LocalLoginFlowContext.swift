import Foundation

public enum LocalLoginFlowContext {
    case autofillExtension(cancelAction: @MainActor () -> Void)
    case passwordApp

    var isExtension: Bool {
        switch self {
        case .autofillExtension: return true
        default: return false
        }
    }

    var isPasswordApp: Bool {
        switch self {
        case .passwordApp: return true
        default: return false
        }
    }
}
