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
}
