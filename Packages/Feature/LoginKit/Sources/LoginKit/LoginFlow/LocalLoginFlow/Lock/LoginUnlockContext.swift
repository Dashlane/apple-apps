import Foundation
import CoreUserTracking

public struct LoginUnlockContext {
    public enum UnlockOrigin {
        case lock
        case login
    }

        public let isBackupCode: Bool?
    public let origin: UnlockOrigin
    public let verificationMode: Definition.VerificationMode
    public let localLoginContext: LocalLoginFlowContext

    public var reason: Definition.Reason {
        switch origin {
        case .lock: return .unlockApp
        case .login: return .login
        }
    }

    public init(verificationMode: Definition.VerificationMode = .none,
                isBackupCode: Bool? = nil,
                origin: UnlockOrigin,
                localLoginContext: LocalLoginFlowContext) {
        self.verificationMode = verificationMode
        self.isBackupCode = isBackupCode
        self.origin = origin
        self.localLoginContext = localLoginContext
    }
}
