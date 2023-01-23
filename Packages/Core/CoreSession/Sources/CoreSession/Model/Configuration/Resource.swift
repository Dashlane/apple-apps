import Foundation
import DashTypes

struct DashlaneResponse<T: Decodable>: Decodable {
    let code: Int?
    let message: String?
    let content: T
}

struct Resource<Parser: ResponseParserProtocol> {
    let endpoint: String
    let method: HTTPMethod
    let params: [String: Encodable]
    let contentFormat: ContentFormat
    let needsAuthentication: Bool
    let parser: Parser

    init(endpoint: Endpoint,
         method: HTTPMethod = .post,
         params: [String: Encodable],
         contentFormat: ContentFormat = .queryString,
         needsAuthentication: Bool = true,
         parser: Parser) {
        self.endpoint = endpoint
        self.method = method
        self.params = params
        self.contentFormat = contentFormat
        self.needsAuthentication = needsAuthentication
        self.parser = parser
    }
}

extension Resource {
    func load(on engine: LegacyWebService, withTimeout timeout: TimeInterval? = nil, completion: @escaping (Result<Parser.ParsedResponse, Error>) -> Void) {
        engine.sendRequest(to: self.endpoint,
                           using: self.method,
                           params: self.params,
                           contentFormat: self.contentFormat,
                           needsAuthentication: self.needsAuthentication,
                           responseParser: self.parser,
                           timeout: timeout,
                           completion: completion)

    }
}
