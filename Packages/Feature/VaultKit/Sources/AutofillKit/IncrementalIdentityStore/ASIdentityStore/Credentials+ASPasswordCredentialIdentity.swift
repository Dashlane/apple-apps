import AuthenticationServices
import Combine
import CorePersonalData
import Foundation

extension Credential {

  var credentialIdentities: [ASPasswordCredentialIdentity] {
    guard !self.subdomainOnly else {
      guard let host = self.url?.host else { return [] }

      return [credentialIdentity(forServiceIdentifier: host)]
    }

    guard let domain = self.url?.domain,
      !displayLogin.isEmpty,
      !password.isEmpty
    else {
      return []
    }

    var domains = Set([domain.name])

    if let linkedDomains = domain.linkedDomains {
      domains.formUnion(linkedDomains)
    }

    domains.formUnion(manualAssociatedDomains)

    domains.formUnion(linkedServices.associatedDomains.map { $0.domain })

    return domains.map(self.credentialIdentity)
  }

  private func credentialIdentity(forServiceIdentifier domain: String)
    -> ASPasswordCredentialIdentity
  {
    let serviceIdentifier = ASCredentialServiceIdentifier(identifier: domain, type: .domain)
    return ASPasswordCredentialIdentity(
      serviceIdentifier: serviceIdentifier,
      user: autofillTitle,
      recordIdentifier: self.id.rawValue)
  }

  var autofillTitle: String {
    guard !title.isEmpty else {
      return displayLogin
    }
    return "\(title) – \(displayLogin)"
  }
}
