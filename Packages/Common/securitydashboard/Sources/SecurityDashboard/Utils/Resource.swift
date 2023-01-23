import Foundation
import DashTypes

struct Resource<Parser: ResponseParserProtocol> {
    let endpoint: String
    let method: HTTPMethod
    let params: [String: Encodable]
    let contentFormat: ContentFormat
    let needsAuthentication: Bool
    let parser: Parser
}

extension Resource {
    func load(on engine: LegacyWebService) async throws -> Parser.ParsedResponse {
        try await engine.sendRequest(to: self.endpoint,
                                     using: self.method,
                                     params: self.params,
                                     contentFormat: self.contentFormat,
                                     needsAuthentication: self.needsAuthentication,
                                     responseParser: self.parser)

    }
}
