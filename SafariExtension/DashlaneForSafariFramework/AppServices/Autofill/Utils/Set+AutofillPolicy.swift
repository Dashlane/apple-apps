import Foundation
import DomainParser

extension Set where Element == AutofillPolicy {
    func policy(forPageAtURL url: String, domainParser: DomainParser) -> AutofillPolicy? {
        let pageAutofillPolicy = first(where: { $0.pageURL == url && $0.level == .page })
        
        guard let domain = domainParser
                .parse(urlString: url)?.name,
              let domainAutofillPolicy = policy(forDomain: domain) else {
            return pageAutofillPolicy
        }
        
        switch pageAutofillPolicy {
        case .none:
            return domainAutofillPolicy
        case let .some(pagePolicy):
            return pagePolicy.policy.isStricterThan(other: domainAutofillPolicy.policy) ? pagePolicy : domainAutofillPolicy
        }
    }
}
