import CoreTypes
import DashlaneAPI
import Foundation

public struct AccountCreationConfiguration: Hashable, Sendable {
  public let email: CoreTypes.Email
  public let password: String
  public let accountType: DashlaneAPI.AccountType

  public var local: LocalConfiguration
  public var hasUserAcceptedEmailMarketing: Bool

  public init(
    email: CoreTypes.Email, password: String, accountType: DashlaneAPI.AccountType,
    local: LocalConfiguration = LocalConfiguration(), hasUserAcceptedEmailMarketing: Bool = false
  ) {
    self.email = email
    self.password = password
    self.accountType = accountType
    self.local = local
    self.hasUserAcceptedEmailMarketing = hasUserAcceptedEmailMarketing
  }
}

public struct LocalConfiguration: Hashable, Sendable {
  public var isBiometricAuthenticationEnabled: Bool
  public var isMasterPasswordResetEnabled: Bool
  public var isRememberMasterPasswordEnabled: Bool
  public var pincode: String?

  public init(
    isBiometricAuthenticationEnabled: Bool = false, isMasterPasswordResetEnabled: Bool = false,
    isRememberMasterPasswordEnabled: Bool = false, pincode: String? = nil
  ) {
    self.isBiometricAuthenticationEnabled = isBiometricAuthenticationEnabled
    self.isMasterPasswordResetEnabled = isMasterPasswordResetEnabled
    self.isRememberMasterPasswordEnabled = isRememberMasterPasswordEnabled
    self.pincode = pincode
  }
}
