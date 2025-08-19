import AuthenticationServices
import Combine
import CorePersonalData
import Foundation
import TOTPGenerator

extension Credential {
  func makeCredentialIdentities() -> [SnapshotSummary.CredentialIdentity] {
    guard let domain = self.url?.domain,
      let host = self.url?.host,
      !displayLogin.isEmpty,
      !password.isEmpty
    else {
      return []
    }

    var domains = Set([self.subdomainOnly ? host : domain.name])

    if !self.subdomainOnly, let linkedDomains = domain.linkedDomains {
      domains.formUnion(linkedDomains)
    }

    domains.formUnion(linkedServices.sanitizedAssociatedDomains())

    let filteredDomains = domains.filter { domain in
      !domains.contains { otherDomain in
        domain.hasSuffix(".\(otherDomain)")
      }
    }

    let otp: SnapshotSummary.CredentialIdentity.OTP? =
      if let otpURL = self.otpURL,
        let conf = try? OTPConfiguration(otpURL: otpURL)
      {
        .init(algorithm: conf.algorithm, digits: conf.digits)
      } else {
        nil
      }

    return filteredDomains.map { domain in
      SnapshotSummary.CredentialIdentity(
        vaultId: self.id,
        serviceIdentifier: domain,
        user: autofillTitle,
        otp: otp)
    }
  }

  var autofillTitle: String {
    guard !title.isEmpty else {
      return displayLogin
    }
    return "\(title) – \(displayLogin)"
  }
}

extension LinkedServices {
  fileprivate func sanitizedAssociatedDomains() -> [String] {
    return associatedDomains.compactMap { domain -> String? in
      var cleanDomain = domain.domain
        .trimmingCharacters(in: .whitespaces)
        .replacing(#/^[a-zA-Z]+:\///#, with: "")

      if let endIndex = cleanDomain.firstIndex(of: "/") {
        cleanDomain = String(cleanDomain[..<endIndex])
      }

      return cleanDomain
    }
  }
}
