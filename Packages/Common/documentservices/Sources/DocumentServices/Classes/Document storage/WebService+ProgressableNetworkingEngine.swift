import Foundation
import CoreNetworking
import DashTypes

protocol WebServiceFile {
    var key: String { get }
    var filename: String { get }
    var data: Data { get }
}

extension LegacyWebServiceImpl: DocumentServices.ProgressableNetworkingEngine {
    public func sendProgressableRequest<R>(to endpoint: Endpoint,
                                           using method: HTTPMethod,
                                           params: [String: Encodable],
                                           contentFormat: ContentFormat,
                                           needsAuthentication: Bool,
                                           responseParser: R,
                                           file: DocumentServices.File?,
                                           keyOrder: [String]?,
                                           completion: @escaping (Result<R.ParsedResponse, Error>) -> Void) -> URLSessionTask where R: ResponseParserProtocol {
        return progressableRequestImplementation(to: endpoint, using: method, params: params, contentFormat: contentFormat, needsAuthentication: needsAuthentication, responseParser: responseParser, file: file, keyOrder: keyOrder, completion: completion)
    }

    public func sendRequest<R>(to endpoint: Endpoint,
                               using method: HTTPMethod,
                               params: [String: Encodable],
                               contentFormat: ContentFormat,
                               needsAuthentication: Bool,
                               responseParser: R,
                               file: DocumentServices.File?,
                               keyOrder: [String]?) async throws -> R.ParsedResponse where R: ResponseParserProtocol {
        return try await requestImplementation(to: endpoint, using: method, params: params, contentFormat: contentFormat, needsAuthentication: needsAuthentication, responseParser: responseParser, file: file, keyOrder: keyOrder)
    }

}

private extension LegacyWebServiceImpl {
    func progressableRequestImplementation<R>(to endpoint: Endpoint,
                                              using method: HTTPMethod,
                                              params: [String: Encodable],
                                              contentFormat: ContentFormat,
                                              needsAuthentication: Bool,
                                              responseParser: R,
                                              file: WebServiceFile?,
                                              keyOrder: [String]?,
                                              completion: @escaping (Result<R.ParsedResponse, Error>) -> Void) -> URLSessionTask where R: ResponseParserProtocol {

        let format: Request.ContentFormat = {
            switch contentFormat {
            case .json: return .json
            case .queryString: return .queryString
            case .multipart: return .multipart
            }
        }()

        var requestBuilder = RequestBuilder(endpoint,
                                            serverConfiguration: serverConfiguration,
                                            method: Request.HTTPMethod.init(rawValue: method.rawValue)!,
                                            contentFormat: format,
                                            keyOrder: keyOrder ?? [],
                                            needsAuthentication: needsAuthentication)
            .addParameters(params)

        if let file = file {
            requestBuilder = requestBuilder.addFile(key: file.key, filename: file.filename, fileContent: file.data)
        }

        let request = requestBuilder.build()

        let resource = CoreNetworking.Resource(request: request) { (data) -> Result<R.ParsedResponse, Error> in
            do {
                return try .success(responseParser.parse(data: data))
            } catch {
                return .failure(error)
            }
        }

        return load(resource, completion: completion)
    }

    func requestImplementation<R>(to endpoint: Endpoint,
                                  using method: HTTPMethod,
                                  params: [String: Encodable],
                                  contentFormat: ContentFormat,
                                  needsAuthentication: Bool,
                                  responseParser: R,
                                  file: WebServiceFile?,
                                  keyOrder: [String]?) async throws -> R.ParsedResponse where R: ResponseParserProtocol {

        let format: Request.ContentFormat = {
            switch contentFormat {
            case .json: return .json
            case .queryString: return .queryString
            case .multipart: return .multipart
            }
        }()

        var requestBuilder = RequestBuilder(endpoint,
                                            serverConfiguration: serverConfiguration,
                                            method: Request.HTTPMethod.init(rawValue: method.rawValue)!,
                                            contentFormat: format,
                                            keyOrder: keyOrder ?? [],
                                            needsAuthentication: needsAuthentication)
            .addParameters(params)

        if let file = file {
            requestBuilder = requestBuilder.addFile(key: file.key, filename: file.filename, fileContent: file.data)
        }

        let request = requestBuilder.build()

        let resource = CoreNetworking.Resource(request: request) { (data) -> Result<R.ParsedResponse, Error> in
            do {
                return try .success(responseParser.parse(data: data))
            } catch {
                return .failure(error)
            }
        }

        return try await load(resource)
    }

}

extension DocumentServices.File: WebServiceFile { }

