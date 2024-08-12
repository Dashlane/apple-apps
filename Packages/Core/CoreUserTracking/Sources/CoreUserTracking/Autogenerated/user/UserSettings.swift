import Foundation

extension UserEvent {

  public struct `UserSettings`: Encodable, UserEventProtocol {
    public static let isPriority = true
    public init(
      `hasAuthenticationWithBiometrics`: Bool? = nil, `hasAuthenticationWithPin`: Bool? = nil,
      `hasAuthenticationWithRememberMe`: Bool? = nil, `hasAuthenticationWithWebauthn`: Bool? = nil,
      `hasAutofillActivated`: Bool? = nil,
      `hasAutomaticTwoFactorAuthenticationTokenCopy`: Bool? = nil, `hasClearClipboard`: Bool? = nil,
      `hasCredentialsProtectWithMasterPassword`: Bool? = nil,
      `hasIdsProtectWithMasterPassword`: Bool? = nil, `hasLockOnExit`: Bool? = nil,
      `hasMasterPasswordBiometricReset`: Bool? = nil,
      `hasPaymentsProtectWithMasterPassword`: Bool? = nil,
      `hasSecureNotesProtectWithMasterPassword`: Bool? = nil,
      `hasUnlockItemWithBiometric`: Bool? = nil, `lockAutoTimeout`: Int? = nil
    ) {
      self.hasAuthenticationWithBiometrics = hasAuthenticationWithBiometrics
      self.hasAuthenticationWithPin = hasAuthenticationWithPin
      self.hasAuthenticationWithRememberMe = hasAuthenticationWithRememberMe
      self.hasAuthenticationWithWebauthn = hasAuthenticationWithWebauthn
      self.hasAutofillActivated = hasAutofillActivated
      self.hasAutomaticTwoFactorAuthenticationTokenCopy =
        hasAutomaticTwoFactorAuthenticationTokenCopy
      self.hasClearClipboard = hasClearClipboard
      self.hasCredentialsProtectWithMasterPassword = hasCredentialsProtectWithMasterPassword
      self.hasIdsProtectWithMasterPassword = hasIdsProtectWithMasterPassword
      self.hasLockOnExit = hasLockOnExit
      self.hasMasterPasswordBiometricReset = hasMasterPasswordBiometricReset
      self.hasPaymentsProtectWithMasterPassword = hasPaymentsProtectWithMasterPassword
      self.hasSecureNotesProtectWithMasterPassword = hasSecureNotesProtectWithMasterPassword
      self.hasUnlockItemWithBiometric = hasUnlockItemWithBiometric
      self.lockAutoTimeout = lockAutoTimeout
    }
    public let hasAuthenticationWithBiometrics: Bool?
    public let hasAuthenticationWithPin: Bool?
    public let hasAuthenticationWithRememberMe: Bool?
    public let hasAuthenticationWithWebauthn: Bool?
    public let hasAutofillActivated: Bool?
    public let hasAutomaticTwoFactorAuthenticationTokenCopy: Bool?
    public let hasClearClipboard: Bool?
    public let hasCredentialsProtectWithMasterPassword: Bool?
    public let hasIdsProtectWithMasterPassword: Bool?
    public let hasLockOnExit: Bool?
    public let hasMasterPasswordBiometricReset: Bool?
    public let hasPaymentsProtectWithMasterPassword: Bool?
    public let hasSecureNotesProtectWithMasterPassword: Bool?
    public let hasUnlockItemWithBiometric: Bool?
    public let lockAutoTimeout: Int?
    public let name = "user_settings"
  }
}
