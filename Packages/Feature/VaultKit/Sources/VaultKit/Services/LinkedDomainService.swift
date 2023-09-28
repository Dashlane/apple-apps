import Foundation
import DashTypes
import CorePersonalData

public class LinkedDomainService: LinkedDomainProvider {

        private let linkedDomains: [String: LinkedDomain]

    public init() {
        let computableLinkedDomain = LinkedDomains.sharedBackend.map(LinkedDomain.init)

        var linkedDomains: [String: LinkedDomain] = [:]
                for group in computableLinkedDomain {
            for domain in group.domains {
                linkedDomains[domain] = group
            }
        }
        self.linkedDomains = linkedDomains
    }

    public subscript(domain: String) -> [String]? {
        linkedDomains[domain]?.domains
    }
}

private class LinkedDomain {
    let domains: [String]
    init(_ domains: [String]) {
        self.domains = domains
    }
}
