import Foundation
import DashTypes
import SwiftTreats

fileprivate struct Tools {
        static func pretty(data: Data?) -> String? {
        guard let data = data else { return nil }
        guard let object = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) else { return nil }
        return pretty(object: object)
    }

        static func pretty(object: Any?) -> String? {
        guard let object = object else { return nil }
        let options: JSONSerialization.WritingOptions
        options = [.prettyPrinted, .sortedKeys]
        guard JSONSerialization.isValidJSONObject(object) == true else {
            return nil
        }
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: options) else {
            return nil
        }
        return String(data: data, encoding: .utf8)
    }
}

public enum WebServiceError: Error, CustomDebugStringConvertible {
    case httpError(statusCode: Int, data: Data?)
    case noData
    case wrongData
    case other

    public var debugDescription: String {
        switch self {
        case .noData:
            return "CoreNetworking.WebServiceError.noData"
        case .wrongData:
            return "CoreNetworking.WebServiceError.wrongData"
        case .other:
            return "CoreNetworking.WebServiceError.other"
        case let .httpError(code, data):
            var baseDescription = "CoreNetworking.WebServiceError.httpError(statusCode: \(code), data: \(String(describing: data)))"

            if let data = data, let decodedData = String(data: data, encoding: .utf8) {
                baseDescription += "\n    Decoded data: \(decodedData)"
            }
            return baseDescription
        }
    }
}

public final class LegacyWebServiceImpl {

    public struct Authentication {
                let login: String
        let uki: String
    }

    private let logger: Logger?
    let session: URLSession
    private var authentication: Authentication?

        public struct Probes {
        public var loadStart: (() -> Void)?
        public var loadCompletion: ((_ success: Bool) -> Void)?
    }
    public var probes = Probes()
    public let serverConfiguration: LegacyWebServiceImpl.Configuration

    public init(session: URLSession, serverConfiguration: LegacyWebServiceImpl.Configuration, logger: Logger? = nil) {
        self.session = session
        self.serverConfiguration = serverConfiguration
        self.logger = logger
    }
    
    public convenience init(serverConfiguration: LegacyWebServiceImpl.Configuration, logger: Logger? = nil) {

                let configuration = URLSessionConfiguration.ephemeral
        self.init(session: URLSession(configuration: configuration, delegate: nil, delegateQueue: .main), serverConfiguration: serverConfiguration, logger: logger)
    }

    public convenience init(platform: Platform = .passwordManager, logger: Logger? = nil) {
        self.init(serverConfiguration: .init(platform: platform), logger: logger)
    }

        public func configureAuthentication(usingLogin login: String, uki: String) {
        self.authentication = .init(login: login, uki: uki)
    }

            public func invalidateAndCancel() {
        self.session.invalidateAndCancel()
    }

                                @discardableResult
    public func load<A>(_ resource: Resource<A>, completion: CompletionBlock<A, Error>?  = nil) -> URLSessionTask {
        self.probes.loadStart?()

        let queue = Thread.isMainThread ? DispatchQueue.main : DispatchQueue.global()

        let _request = self.request(for: resource)
        self.logger?.info(_request.infoDescription)
        self.logger?.debug(_request.debugDescription)

        let task = self.session.dataTask(with: _request) { data, response, error in
            self.logResponse(data, response, error)

            let result = LegacyWebServiceImpl.processResponse(resource, data, response, error)
            queue.async {
                self.probes.loadCompletion?(error == nil)
                completion?(result)
            }
        }
        task.resume()
        return task
    }
    
    public func load<A>(_ resource: Resource<A>) async throws -> A {
        self.probes.loadStart?()

        let _request = self.request(for: resource)
        self.logger?.info(_request.infoDescription)
        self.logger?.debug(_request.debugDescription)
        
        do {
            let (data, response) = try await self.session.data(for: _request)
            self.logResponse(data, response, nil)
            let result = LegacyWebServiceImpl.processResponse(resource, data, response, nil)
            self.probes.loadCompletion?(true)
            return try result.get()
        } catch {
            self.probes.loadCompletion?(false)
            throw error
        }
    }

    func request<A>( for resource: Resource<A> ) -> URLRequest {
        
        var request = resource.request
        if request.needsAuthentication,
            let authentication {
            request = request.authenticated(using: authentication, serverConfiguration: serverConfiguration)
        } else {
            request = request.nonAuthenticated(serverConfiguration: serverConfiguration)
        }

        return request.urlRequest
    }
    
    static func processResponse<A>( _ resource: Resource<A>, _ data: Data?, _ response: URLResponse?, _ error: Error? ) -> Result<A, Error> {
        
        let result: Result<A, Error>
        
        if let response = response as? HTTPURLResponse {
            if 200 ..< 300 ~= response.statusCode {
                if let data = data {
                                        result = resource.parse(data)
                    
                } else {
                    result = .failure(WebServiceError.noData)
                }
                
            } else {
                result = .failure(WebServiceError.httpError(statusCode: response.statusCode, data: data))
            }
            
        } else if let error = error {
            result = .failure(error)
            
        } else {
            result = .failure(WebServiceError.other)
        }

        return result
    }

    private func logResponse(_ data: Data?, _ response: URLResponse?, _ error: Error?) {
        guard let httpResponse = response as? HTTPURLResponse else { return }
        self.logger?.info(httpResponse.infoDescription)
        self.logger?.debug {
            var debugMessage = String(describing: response?.debugDescription)

            if let error = error {
                debugMessage += "\n  Error: \(error)"
            }

            debugMessage += "\n  Body: "
            debugMessage += debugRepresentation(of: data)
            return debugMessage
        }
    }
}

extension URLRequest {
        public var infoDescription: String {
        return "Request: \(String(describing: httpMethod)) \(String(describing: url))\n  auth header: \(String(describing: allHTTPHeaderFields?["Authorization"])))"
    }
        public var debugDescription: String {
        var description = ""

                if let headersString = Tools.pretty(object: allHTTPHeaderFields) {
           description += "\n  Headers: \(headersString)"
        }

                let contentEncoding = allHTTPHeaderFields?["Content-Encoding"]
        var body = httpBody
        if contentEncoding == "gzip" {
            body = body?.gzipDecompressed()
            description += "\n  Body (unzipped): "
        } else {
            description += "\n  Body: "
        }

        description += debugRepresentation(of: body)
        if let bodyRepresentation = Tools.pretty(data: body) {
            description += bodyRepresentation.prefix(2048)
        } else if let body = httpBody, let bodyRepresentation = String(data: body, encoding: .utf8)  {
            description += bodyRepresentation.prefix(2048)
        } else {
            description += "(non-utf8 compliant)"
        }
        return description
    }
}

extension HTTPURLResponse {
        public var infoDescription: String {
        return "Response: \(statusCode) \(String(describing: url))\n  auth header: \(String(describing: allHeaderFields["Authorization"])))"
    }
        override open var debugDescription: String {
        var description = ""

                if let headersString = Tools.pretty(object: allHeaderFields) {
            description += "\n  Headers: \(headersString)"
        }

        return description
    }
}

private func debugRepresentation(of payload: Data?) -> String {
    let representation: String

    if let data = payload {
        if let bodyRepresentation = Tools.pretty(data: data) {
            representation = String(bodyRepresentation.prefix(2048))
        } else if let bodyRepresentation = String(data: data, encoding: .utf8)  {
            representation = String(bodyRepresentation.prefix(2048))
        } else {
            representation = "(non-utf8 compliant)"
        }
    } else {
        representation = "nil"
    }

    return representation
}
