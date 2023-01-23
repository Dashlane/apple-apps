import Foundation

public struct Domain: Equatable, Codable {
    public let name: String
    public let publicSuffix: String?
    public let linkedDomains: [String]?
    
    public init(name: String, publicSuffix: String?, linkedDomains: [String]? = nil) {
        self.name = name
        self.publicSuffix = publicSuffix
        self.linkedDomains = linkedDomains
    }
}
