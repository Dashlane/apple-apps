import Foundation
import CorePersonalData
import DomainParser
import DashTypes

public struct PersonalDataURLDecoder: CorePersonalData.PersonalDataURLDecoder {
  
    let domainParser: DomainParserProtocol
    let linkedDomainService: LinkedDomainProvider
    
    public init(domainParser: DomainParserProtocol, linkedDomainService: LinkedDomainProvider) {
        self.domainParser = domainParser
        self.linkedDomainService = linkedDomainService
    }
    
    public func decodeURL(_ url: String) throws -> PersonalDataURL {
        var domain: Domain?
        let urlHost = domainParser.parseHost(urlString: url)
        if let urlHost = urlHost {
            domain = domainParser.parse(urlHost: urlHost)
        }
        if let parsedDomain = domain,
            let linkedDomains = linkedDomainService[parsedDomain.name] {
            domain = Domain(name: parsedDomain.name,
                            publicSuffix: parsedDomain.publicSuffix,
                            linkedDomains: linkedDomains)
        }
        return PersonalDataURL(rawValue: url, domain: domain, host: urlHost)
    }
}

public extension DomainParser {
    static func defaultConfiguration() throws -> DomainParser {
        return try DomainParser(quickParsing: true)
    }
}

public extension DomainParserProtocol {
    fileprivate func parseHost(urlString: String) -> String? {
        guard let escapedURLString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let url = URL(string: escapedURLString.starts(with: "http") ? escapedURLString : "_" + escapedURLString),
            let urlHost = url.host?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
                return nil
        }
        return urlHost
    }

    fileprivate func parse(urlHost: String) -> Domain? {
        guard let parsedHost = parse(host: urlHost),
            let domain = parsedHost.domain else {
                return Domain(name: urlHost, publicSuffix: nil)
        }

        return Domain(name: domain, publicSuffix: parsedHost.publicSuffix)
    }
    
    func parse(urlString: String) -> Domain? {
        guard let host = parseHost(urlString: urlString) else { return nil }
        let domain = parse(urlHost: host)
        return domain
    }
}
