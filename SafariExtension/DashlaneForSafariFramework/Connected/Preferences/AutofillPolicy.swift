import Foundation
import CoreSettings
import CorePersonalData
import DomainParser

public class AutofillPolicy: Hashable, Equatable, Codable {
    
    public enum Level: String, Codable, CaseIterable, Identifiable {
        case domain
        case page

        public var id: String { self.rawValue }

        public var title: String {
            switch self {
            case .domain: return L10n.Localizable.safariAutofillWebsiteText
            case .page: return L10n.Localizable.safariAutofillPageText
            }
        }

    }

    public enum Policy: Int, Codable, CaseIterable, Identifiable {
        case everything = 0
        case loginPasswordsOnly
        case disabled
        
        public var id: Int { self.rawValue }

        public var title: String {
            switch self {
            case .everything: return L10n.Localizable.safariAutofillEverything
            case .loginPasswordsOnly: return L10n.Localizable.safariAutofillLoginPasswords
            case .disabled: return L10n.Localizable.safariAutofillNothing
            }
        }
        
        func isStricterThan(other: Policy) -> Bool {
            rawValue > other.rawValue
        }
    }

    public var policy: Policy
    public var level: Level
    public let domain: String
    public let pageURL: String
    
    init(policy: Policy, level: Level, domain: String, pageURL: String = "") {
        self.policy = policy
        self.level = level
        self.domain = domain
        self.pageURL = level == .page ? pageURL : ""
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(domain)
        hasher.combine(pageURL)
    }
    
    var subject: String {
        switch level {
        case .domain:
            return domain
        case .page:
            return pageURL
        }
    }
    
    var isDefault: Bool {
        return policy == .everything
    }
    
    public static func == (lhs: AutofillPolicy, rhs: AutofillPolicy) -> Bool {
        lhs.domain == rhs.domain
            && lhs.pageURL == rhs.pageURL
    }
}

extension AutofillPolicy {
    func isMatching(url: String) -> Bool{
        switch level {
        case .domain:
            return url == domain
        case .page:
            return url == pageURL || domain == url
        }
    }
}
