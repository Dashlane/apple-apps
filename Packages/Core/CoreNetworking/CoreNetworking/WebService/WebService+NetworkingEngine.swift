import Foundation
import DashTypes

extension LegacyWebServiceImpl: LegacyWebService {
    public func sendRequest<R>(to endpoint: Endpoint, using method: HTTPMethod, params: [String: Encodable], contentFormat: ContentFormat, needsAuthentication: Bool, responseParser: R, timeout: TimeInterval?) async throws -> R.ParsedResponse where R: ResponseParserProtocol {
        let request = RequestBuilder(endpoint,
                                     serverConfiguration: serverConfiguration,
                                     method: .init(from: method),
                                     contentFormat: .init(from: contentFormat),
                                     needsAuthentication: needsAuthentication,
                                     timeout: timeout)
            .addParameters(params)
            .build()

        let resource: Resource<R.ParsedResponse> = Resource(request: request) { (data) -> Result<R.ParsedResponse, Error> in
            return Result { try responseParser.parse(data: data) }
        }
        return try await load(resource)
    }

    public func sendRequest<R>(to endpoint: Endpoint,
                               using method: HTTPMethod,
                               params: [String: Encodable],
                               contentFormat: ContentFormat,
                               needsAuthentication: Bool,
                               responseParser: R,
                               timeout: TimeInterval?,
                               completion: @escaping (Result<R.ParsedResponse, Error>) -> Void) where R: ResponseParserProtocol {
        let request = RequestBuilder(endpoint,
                                     serverConfiguration: serverConfiguration,
                                     method: .init(from: method),
                                     contentFormat: .init(from: contentFormat),
                                     needsAuthentication: needsAuthentication,
                                     timeout: timeout)
            .addParameters(params)
            .build()

        let resource: Resource<R.ParsedResponse> = Resource(request: request) { (data) -> Result<R.ParsedResponse, Error> in
            return Result { try responseParser.parse(data: data) }
        }
        load(resource, completion: completion)
    }
}

private extension  Request.HTTPMethod {
    init(from method: HTTPMethod) {
        switch method {
        case .get:
            self = .get
        case .post:
            self = .post
        }
    }
}

private extension Request.ContentFormat {
    init(from contentFormat: ContentFormat) {
        switch contentFormat {
        case .json:
            self = .json
        case .queryString:
            self = .queryString
        case .multipart:
            self = .multipart
        }
    }
}
