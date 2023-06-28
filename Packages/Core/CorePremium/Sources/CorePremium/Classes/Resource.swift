import Foundation
import DashTypes

public struct File {
    public let key: String
    public let filename: String
    public let data: Data
}

struct Resource<Parser: ResponseParserProtocol> {
    let endpoint: String
    let method: HTTPMethod
    let params: [String: Encodable]
    let contentFormat: ContentFormat
    let needsAuthentication: Bool
    let file: File?
    let keyOrder: [String]?
    let parser: Parser

    init(endpoint: String,
         method: HTTPMethod,
         params: [String: Encodable],
         contentFormat: ContentFormat,
         needsAuthentication: Bool,
         file: File? = nil,
         keyOrder: [String]? = nil,
         parser: Parser) {
        self.endpoint = endpoint
        self.method = method
        self.params = params
        self.contentFormat = contentFormat
        self.needsAuthentication = needsAuthentication
        self.file = file
        self.keyOrder = keyOrder
        self.parser = parser
    }
}

extension Resource {
    func load(on engine: LegacyWebService, completion: @escaping (Result<Parser.ParsedResponse, Error>) -> Void) {
        engine.sendRequest(to: self.endpoint,
                                              using: self.method,
                                              params: self.params,
                                              contentFormat: self.contentFormat,
                                              needsAuthentication: self.needsAuthentication,
                                              responseParser: self.parser,
                                              completion: completion)
    }
}
