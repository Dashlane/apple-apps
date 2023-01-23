import SwiftTreats

public enum DomainSource : String, Codable, Defaultable, CaseIterable {
    public static let defaultValue: DomainSource = .manual
    
    case manual
    case remember
}

public struct LinkedServices: Codable {
    public struct AssociatedDomain: Codable, Equatable {
        public var domain: String
        public var source: DomainSource
        
        public init(domain: String, source: DomainSource) {
            self.domain = domain
            self.source = source
        }
    }
    
    public enum CodingKeys: String, CodingKey {
        case associatedDomains = "associated_domains"
    }

    public var associatedDomains: [AssociatedDomain]
    
    public init(associatedDomains: [AssociatedDomain]) {
        self.associatedDomains = associatedDomains
    }
}

extension LinkedServices: Defaultable {
    public static var defaultValue: Self {
        return LinkedServices(associatedDomains: [])
    }
}

extension LinkedServices: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        guard lhs.associatedDomains.count == rhs.associatedDomains.count else {
            return false
        }
        
        return zip(lhs.associatedDomains, rhs.associatedDomains).allSatisfy { $0.0 == $0.1 }
    }
}
