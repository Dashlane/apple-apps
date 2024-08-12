import CorePersonalData
import Foundation
import SwiftTreats

extension Array where Element == Credential {

  public func matchingCredentials(forDomain domain: String) -> [Credential] {
    guard !domain.isEmpty else { return [] }
    let spacelessDomain = domain.removeWhitespacesCharacters()
    return self.filter({
      if $0.title.localizedCaseInsensitiveContains(domain)
        || $0.title.removeWhitespacesCharacters().localizedCaseInsensitiveContains(spacelessDomain)
      {
        return true
      }
      guard let credentialDomain = $0.url?.domain?.name else {
        return false
      }

      let domainMatch =
        credentialDomain.localizedCaseInsensitiveContains(domain)
        || credentialDomain.localizedCaseInsensitiveContains(spacelessDomain)

      return domainMatch
    })
  }

  public func filterCredentialsHavingOTPSet() -> [Credential] {
    return self.filter {
      $0.otpURL == nil
    }
  }
}
