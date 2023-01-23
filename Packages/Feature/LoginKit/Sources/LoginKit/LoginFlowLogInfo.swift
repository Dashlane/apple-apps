import Foundation
import CoreUserTracking

public struct LoginFlowLogInfo {
    public let loginMode: Definition.Mode
    public let verificationMode: Definition.VerificationMode
    public let isBackupCode: Bool?

    public init(loginMode: Definition.Mode,
                verificationMode: Definition.VerificationMode = Definition.VerificationMode.none,
                isBackupCode: Bool? = nil) {
        self.loginMode = loginMode
        self.verificationMode = verificationMode
        self.isBackupCode = isBackupCode
    }
}
