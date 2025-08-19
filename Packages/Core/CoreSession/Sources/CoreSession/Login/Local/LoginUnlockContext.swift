import Foundation
import UserTrackingFoundation

public struct LoginUnlockContext: Sendable {

  public let isBackupCode: Bool
  public let origin: UnlockContext
  public let verificationMode: Definition.VerificationMode
  public let localLoginContext: UnlockOriginProcess

  public var reason: Definition.Reason {
    switch origin {
    case .lock: return .unlockApp
    case .login: return .login
    }
  }

  public init(
    verificationMode: Definition.VerificationMode = .none,
    isBackupCode: Bool = false,
    origin: UnlockContext,
    localLoginContext: UnlockOriginProcess
  ) {
    self.verificationMode = verificationMode
    self.isBackupCode = isBackupCode
    self.origin = origin
    self.localLoginContext = localLoginContext
  }
}
