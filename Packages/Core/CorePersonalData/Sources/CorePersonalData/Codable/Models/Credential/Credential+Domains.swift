import CoreTypes
import Foundation

extension Credential {
  public func allDomains() -> [String] {
    var credentialDomains = [String]()
    if let mainUrl = url?.openableURL?.host {
      credentialDomains.append(mainUrl)
    }

    credentialDomains += linkedServices.associatedDomains.map { $0.domain }

    if let linkedDomains = url?.domain?.linkedDomains {
      credentialDomains += linkedDomains
    }

    return credentialDomains
  }
}
