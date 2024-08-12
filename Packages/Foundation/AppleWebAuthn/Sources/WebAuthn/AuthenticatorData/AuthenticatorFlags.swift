import Foundation

public struct AuthenticatorFlags: Equatable {

  private enum Flag: UInt8 {
    case userPresent = 0b00000001
    case userVerified = 0b00000100
    case backupEligibility = 0b00001000
    case backupState = 0b00010000
    case attestedCredDataIncluded = 0b01000000
    case extensionDataIncluded = 0b10000000
  }

  let userPresent: Bool
  let userVerified: Bool
  let isBackupEligible: Bool
  let isCurrentlyBackedUp: Bool
  let attestedCredentialData: Bool
  let extensionDataIncluded: Bool

  public init(
    userPresent: Bool = false,
    userVerified: Bool = false,
    isBackupEligible: Bool = false,
    isCurrentlyBackedUp: Bool = false,
    attestedCredentialData: Bool = false,
    extensionDataIncluded: Bool = false
  ) {
    self.userPresent = userPresent
    self.userVerified = userVerified
    self.isBackupEligible = isBackupEligible
    self.isCurrentlyBackedUp = isCurrentlyBackedUp
    self.attestedCredentialData = attestedCredentialData
    self.extensionDataIncluded = extensionDataIncluded
  }

  public init(flag: UInt8) {
    userPresent = (flag & Flag.userPresent.rawValue) != 0
    userVerified = (flag & Flag.userVerified.rawValue) != 0
    isBackupEligible = (flag & Flag.backupEligibility.rawValue) != 0
    isCurrentlyBackedUp = (flag & Flag.backupState.rawValue) != 0
    attestedCredentialData = (flag & Flag.attestedCredDataIncluded.rawValue) != 0
    extensionDataIncluded = (flag & Flag.extensionDataIncluded.rawValue) != 0
  }
}

extension AuthenticatorFlags {

  func byteRepresentation() -> UInt8 {
    var result: UInt8 = 0b00000000

    if userPresent {
      result |= Flag.userPresent.rawValue
    }
    if userVerified {
      result |= Flag.userVerified.rawValue
    }
    if isBackupEligible {
      result |= Flag.backupEligibility.rawValue
    }
    if isCurrentlyBackedUp {
      result |= Flag.backupState.rawValue
    }
    if attestedCredentialData {
      result |= Flag.attestedCredDataIncluded.rawValue
    }
    if extensionDataIncluded {
      result |= Flag.extensionDataIncluded.rawValue
    }
    return result
  }
}
