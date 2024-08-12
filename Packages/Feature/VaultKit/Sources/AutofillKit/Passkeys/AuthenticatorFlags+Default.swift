import Foundation
import WebAuthn

extension AuthenticatorFlags {
  public static func assertion(hasUserBeenVerified: Bool) -> AuthenticatorFlags {
    AuthenticatorFlags(
      userPresent: true,
      userVerified: hasUserBeenVerified,
      isBackupEligible: true,
      isCurrentlyBackedUp: true,
      attestedCredentialData: false,
      extensionDataIncluded: false)
  }

  public static func registration(hasUserBeenVerified: Bool) -> AuthenticatorFlags {
    AuthenticatorFlags(
      userPresent: true,
      userVerified: hasUserBeenVerified,
      isBackupEligible: true,
      isCurrentlyBackedUp: true,
      attestedCredentialData: true,
      extensionDataIncluded: false)
  }
}
