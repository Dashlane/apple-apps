import Foundation
import DashTypes

protocol GetIconServiceProtocol {
    func iconDescription(for domain: Domain, format: DomainIconFormat) async throws -> [IconDescription]
}

struct GetIconService: GetIconServiceProtocol {
    private static let serviceName = "/2/iconcrawler/getIcons"
    private let networkEngine: LegacyWebService
    private let logger: Logger

    init(networkEngine: LegacyWebService, logger: Logger) {
        self.networkEngine = networkEngine
        self.logger = logger
    }

                func iconDescription(for domain: Domain, format: DomainIconFormat) async throws -> [IconDescription] {
        return try await networkEngine.sendRequest(to: GetIconService.serviceName,
                                                   using: .post,
                                                   params: try parameters(forDomain: domain, format: format),
                                                   contentFormat: ContentFormat.queryString,
                                                   needsAuthentication: false,
                                                   responseParser: self)
    }

    private func parameters(forDomain domain: Domain, format: DomainIconFormat) throws -> [String: Encodable] {
        let encoder = JSONEncoder()
        let serializedDomainInfo = try encoder.encode([[
            "domain": domain.name,
            "type": format.parameterValue
            ]])
        return ["domainsInfo": String(data: serializedDomainInfo, encoding: .utf8) ?? ""]
    }

}

extension GetIconService: ResponseParserProtocol {
    func parse(data: Data) throws -> [IconDescription] {
        let decoder = JSONDecoder()
        let response = try decoder.decode(GetIconServiceResponse.self, from: data)
        return response.content
    }
}

struct IconDescription: Decodable {
    let domain: String
            let url: URL?
    let date: Date?
    let type: String?
    let backgroundColor: String
    let mainColor: String
    let fallbackColor: String
}

private struct GetIconServiceResponse: Decodable {
    let content: [IconDescription]
}
