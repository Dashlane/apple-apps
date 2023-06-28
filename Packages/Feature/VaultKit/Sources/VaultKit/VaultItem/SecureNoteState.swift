import Foundation

public enum SecureNoteState {
    case disabled
    case limited
    case enabled

    public init(isSecureNoteDisabled: Bool, isSecureNoteLimited: Bool) {
        if isSecureNoteDisabled {
            self = .disabled
        } else if isSecureNoteLimited {
            self = .limited
        } else {
            self = .enabled
        }
    }
}
