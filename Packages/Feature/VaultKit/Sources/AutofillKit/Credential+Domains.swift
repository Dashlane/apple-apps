import Foundation
import DashTypes
import CorePersonalData

public extension Credential {
    func allDomains(using linkedDomainsProvider: LinkedDomainProvider) -> [String] {
                        var credentialDomains = [String]()
        if let mainUrl = url?.openableURL?.host {
            credentialDomains.append(mainUrl)
        }

                credentialDomains += linkedServices.associatedDomains.map { $0.domain }

                let domainName = url?.domain?.name ?? ""
        credentialDomains += linkedDomainsProvider[domainName] ?? []

        return credentialDomains
    }
}
