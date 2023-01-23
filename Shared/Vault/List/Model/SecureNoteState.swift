import Foundation

enum SecureNoteState {
    case disabled
    case limited
    case enabled
    
    init(isSecureNoteDisabled: Bool, isSecureNoteLimited: Bool) {
        if isSecureNoteDisabled {
            self = .disabled
        } else if isSecureNoteLimited {
            self = .limited
        } else {
            self = .enabled
        }
    }
}
