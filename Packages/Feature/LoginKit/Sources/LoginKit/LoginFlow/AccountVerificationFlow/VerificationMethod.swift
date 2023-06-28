import Foundation

public enum PushType {
    case duo
    case authenticator
}

public enum VerificationMethod {
    case emailToken
    case totp(PushType?)
    case authenticatorPush

    var pushType: PushType? {
        switch self {
        case let .totp(type):
            return type
        default:
            return nil
        }
    }
}
