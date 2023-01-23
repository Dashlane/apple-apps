import Foundation
import DashTypes

public extension Credential {
    func isMatching(_ domain: Domain) -> Bool {
        guard let urlDomain = url?.domain else {
            return false
        }
        return urlDomain == domain
            || (urlDomain.linkedDomains ?? []).contains(domain.name)
    }
}
