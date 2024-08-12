import AuthenticationServices
import CorePersonalData
import CoreUserTracking
import Foundation

public struct CredentialSelection {

  public enum SelectedCredential {
    case credential(Credential)
    case passkey(Passkey)
  }

  public let credential: SelectedCredential
  public let visitedWebsite: String?

  public init(credential: SelectedCredential, visitedWebsite: String?) {
    self.credential = credential
    self.visitedWebsite = visitedWebsite
  }
}
