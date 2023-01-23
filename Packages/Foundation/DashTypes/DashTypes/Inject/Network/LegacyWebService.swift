import Foundation

public protocol ResponseParserProtocol {
    associatedtype ParsedResponse
    func parse(data: Data) throws -> ParsedResponse
}

public enum ContentFormat {
    case json
    case queryString
    case multipart
}

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

public typealias Endpoint = String

public protocol LegacyWebService {

        func sendRequest<R: ResponseParserProtocol>(to endpoint: Endpoint,
                                                using method: HTTPMethod,
                                                params: [String: Encodable],
                                                contentFormat: ContentFormat,
                                                needsAuthentication: Bool,
                                                responseParser: R,
                                                timeout: TimeInterval?,
                                                completion:  @escaping (Result<R.ParsedResponse, Error>) -> Void)
    
    func sendRequest<R: ResponseParserProtocol>(to endpoint: Endpoint,
                                                using method: HTTPMethod,
                                                params: [String: Encodable],
                                                contentFormat: ContentFormat,
                                                needsAuthentication: Bool,
                                                responseParser: R,
                                                timeout: TimeInterval?) async throws -> R.ParsedResponse
}

public extension LegacyWebService {
    func sendRequest<R: ResponseParserProtocol>(to endpoint: Endpoint,
                                                using method: HTTPMethod,
                                                params: [String: Encodable],
                                                contentFormat: ContentFormat,
                                                needsAuthentication: Bool,
                                                responseParser: R,
                                                completion:  @escaping (Result<R.ParsedResponse, Error>) -> Void) {
        sendRequest(to: endpoint, using: method, params: params, contentFormat: contentFormat, needsAuthentication: needsAuthentication, responseParser: responseParser, timeout: nil, completion: completion)
    }

    func sendRequest<R: ResponseParserProtocol>(to endpoint: Endpoint,
                                                using method: HTTPMethod,
                                                params: [String: Encodable],
                                                contentFormat: ContentFormat,
                                                needsAuthentication: Bool,
                                                responseParser: R) async throws -> R.ParsedResponse {
        try await sendRequest(to: endpoint, using: method, params: params, contentFormat: contentFormat, needsAuthentication: needsAuthentication, responseParser: responseParser, timeout: nil)
    }
    
}


public extension LegacyWebService {
    
     func sendSynchronousRequest<R>(to endpoint: Endpoint, using method: DashTypes.HTTPMethod, params: [String: Encodable], contentFormat: DashTypes.ContentFormat, needsAuthentication: Bool, responseParser: R, timeout: TimeInterval? = nil) throws -> R.ParsedResponse where R: ResponseParserProtocol {
        
        let semaphore = DispatchSemaphore(value: 0)
        var parsedResult: Result<R.ParsedResponse, Error>!
        self.sendRequest(to: endpoint, using: method, params: params, contentFormat: contentFormat, needsAuthentication: needsAuthentication, responseParser: responseParser, timeout: timeout) { result in
            parsedResult = result
            semaphore.signal()
        }
        semaphore.wait()
        return try parsedResult.get()
    }
}

public extension LegacyWebService {
    
    func sendRequest<R: ResponseParserProtocol>(to endpoint: Endpoint,
                                                using method: HTTPMethod,
                                                params: [String: Encodable],
                                                contentFormat: ContentFormat,
                                                needsAuthentication: Bool,
                                                responseParser: R,
                                                timeout: TimeInterval?) async throws -> R.ParsedResponse {
        return try await withCheckedThrowingContinuation { continuation in
            sendRequest(to: endpoint, using: method, params: params, contentFormat: contentFormat, needsAuthentication: needsAuthentication, responseParser: responseParser, timeout: timeout) { result in
                continuation.resume(with: result)
            }
        }
    }
    
}

public class MockWebService: LegacyWebService {

    public var response: String

    public init(response: String = "") {
        self.response = response
    }

    public func sendRequest<R>(to endpoint: Endpoint, using method: HTTPMethod, params: [String : Encodable], contentFormat: ContentFormat, needsAuthentication: Bool, responseParser: R, timeout: TimeInterval?, completion: @escaping (Result<R.ParsedResponse, Error>) -> Void) where R : ResponseParserProtocol {
        do {
            let result = try responseParser.parse(data: response.data(using: .utf8)!)
            completion(.success(result))
        } catch {
            completion(.failure(error))
        }
    }
}
