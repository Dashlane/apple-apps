import Foundation

public enum StateVariant {
    case county
    case state
}

extension Address {
    public var stateVariant: StateVariant {
        if mode == .unitedKingdom {
            return .county
        } else {
            return .state
        }
    }
}
