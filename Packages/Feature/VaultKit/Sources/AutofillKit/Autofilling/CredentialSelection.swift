import AuthenticationServices
import CorePersonalData
import Foundation
import UserTrackingFoundation

public struct CredentialSelection {

  public enum SelectedCredential {
    case password(Credential)
    case otp(Credential)
    case passkey(Passkey)
  }

  public let credential: SelectedCredential
  public let visitedWebsite: String?

  public init(credential: SelectedCredential, visitedWebsite: String?) {
    self.credential = credential
    self.visitedWebsite = visitedWebsite
  }
}
