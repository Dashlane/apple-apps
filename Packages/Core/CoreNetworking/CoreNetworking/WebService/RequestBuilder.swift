import Foundation
import DashTypes
import DashlaneAPI

public enum ParameterValue {
    case simple(value: Encodable)
    case file(name: String, content: Data)
    
    var value: Encodable {
        switch self {
        case let .simple(value):
            return value
        case let .file(_, content):
            return content
        }
    }
}

public struct Request {
    
    public enum HTTPMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case update = "UPDATE"
        case delete = "DELETE"
        case patch = "PATCH"
    
    }
    
    public enum ContentFormat {
        case json, queryString, multipart
        
        var contentType: String {
            switch self {
            case .queryString:
                return "application/x-www-form-urlencoded"
            case .json:
                return "application/json"
            case .multipart:
                return "multipart/form-data; boundary="
            }
        }
    }
    
    struct Constants {
        static let dataCompressionThreshold = 860
    }
    
    public let request: URLRequest
    public let params: [String: ParameterValue]
    public let needsAuthentication: Bool
    public let contentFormat: ContentFormat
    public let keyOrder: [String]
    public let multipartBoundary: String

    private var _postData: Data? = nil
    
    init(request: URLRequest,
         params: [String: ParameterValue],
         needsAuthentication: Bool,
         contentFormat: ContentFormat,
         postData: Data? = nil,
         keyOrder: [String] = [],
         multipartBoundary: String) {
        self.request = request
        self.params = params
        self.contentFormat  = contentFormat
        self._postData = postData
        self.needsAuthentication = needsAuthentication
        self.keyOrder = keyOrder
        self.multipartBoundary = multipartBoundary
    }
    
    public func authenticated(using authentication: LegacyWebServiceImpl.Authentication,
                              serverConfiguration: LegacyWebServiceImpl.Configuration) -> Request
    {
        var request = self.request
        var params = self.params
        
        if needsAuthentication {
            params[RequestKey.login] = .simple(value: authentication.login)
            params[RequestKey.uki] = .simple(value: authentication.uki)
            request.addValue(UserAgent(platform: serverConfiguration.platform).description, forHTTPHeaderField: "User-Agent")
            request.addAdditionalHeaders(from: serverConfiguration)
        } else {
            request.addValue(UserAgent(platform: serverConfiguration.platform).description, forHTTPHeaderField: "User-Agent")
        }
        return Request(request: request,
                       params: params,
                       needsAuthentication: false,
                       contentFormat: self.contentFormat,
                       postData: self._postData,
                       multipartBoundary: multipartBoundary)
    }
    
    public func nonAuthenticated(serverConfiguration: LegacyWebServiceImpl.Configuration) -> Request
    {
        var request = self.request
        let params = self.params
        request.addValue(UserAgent(platform: serverConfiguration.platform).description, forHTTPHeaderField: "User-Agent")
        serverConfiguration.environment.additionalHeaders.forEach {
            request.addValue($0.value, forHTTPHeaderField: $0.key)
        }
        return Request(request: request,
                       params: params,
                       needsAuthentication: false,
                       contentFormat: self.contentFormat,
                       postData: self._postData,
                       keyOrder: self.keyOrder,
                       multipartBoundary: multipartBoundary)
    }
    
    private func buildURLRequest() -> URLRequest {
        var request = self.request
        request.httpBody = self.postData
        if let host = self.request.url?.hostWithPort {
            request.setValue(host, forHTTPHeaderField: "Host")
        }
        var contentType = contentFormat.contentType
        if contentFormat == .multipart {
            contentType += multipartBoundary
        }
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        return request
    }
    
    
    public var urlRequest: URLRequest {
        
        var request = self.buildURLRequest()
        
                if contentFormat != .multipart,
            let httpBody = request.httpBody,
            httpBody.count > Constants.dataCompressionThreshold {
            request.httpBody = httpBody.gzipCompressed()
            request.setValue("gzip", forHTTPHeaderField: "Content-Encoding")
        }
        
        let postLength = (request.httpBody?.count) ?? 0
        request.setValue("\(postLength)", forHTTPHeaderField: "Content-Length")
        request.cachePolicy = .reloadIgnoringCacheData

        return request
    }
    public mutating func setPostData(_ data: Data?) {
        self._postData = data
    }
    
    private func multipartFileEntry(boundary: String, fieldName: String, filename: String, data: Data) -> Data {
        return """
            --\(multipartBoundary)\r
            Content-Disposition: form-data; name="\(fieldName)"; filename="\(filename)"\r
            Content-Type: application/octet-stream\r
            \r\n
            """.data(using: .utf8)! + data
    }

    private func multipartValueEntry(boundary: String, fieldName: String, value: String) -> Data {
        return """
            --\(multipartBoundary)\r
            Content-Disposition: form-data; name="\(fieldName)"\r
            \r
            \(value)
            """.data(using: .utf8)!

    }
    
    private func multipartPostData(fromParams params: [String: ParameterValue]) -> Data {
        let multipartParams = params.reduce(into: [String: Data](), { result, next in
            switch next.value {
            case let .file(filename, content):
                result[next.key] = multipartFileEntry(boundary: multipartBoundary,
                                                      fieldName: next.key,
                                                      filename: filename,
                                                      data: content)
            case let .simple(value):
                result[next.key] = multipartValueEntry(boundary: multipartBoundary,
                                                       fieldName: next.key,
                                                       value: "\(value)")
            }
        })
        let multipartEnd = "\r\n--\(multipartBoundary)--\r\n".data(using: .utf8)!
        let multipartNewLine = "\r\n".data(using: .utf8)!
        if keyOrder.count > 0 {
            var parts = [Data?]()
            keyOrder.forEach({ key in
                parts.append(multipartParams[key])
            })
            return parts
				.compactMap { $0 }
                .reduce(Data()) { result, next in
                    result.isEmpty ? next : result + multipartNewLine + next
                }
                + multipartEnd
        } else {
            return multipartParams
                .map { $0.value }
                .reduce(Data()) { result, next in
                    result.isEmpty ? next : result + multipartNewLine + next
                }
                + multipartEnd
        }
    }
    
    private func jsonPostData(fromParams params: [String: ParameterValue]) -> Data? {

        guard self.request.httpMethod != HTTPMethod.get.rawValue else {
            return Data()
        }

        let encodableDic = params.mapValues { $0.value }.mapValues(EncodableWrapper.init)
        return try? JSONEncoder().encode(encodableDic)
    }
    
    private func queryStringPostData(fromParams params: [String: ParameterValue]) -> Data? {
        let sortedParams = params.sorted { $0.key < $1.key }
		return sortedParams.compactMap { pair in
            let str = "\(pair.value.value)"
            if let encoded = str.addingPercentEncoding(withAllowedCharacters: .alphanumerics) {
                return "\(pair.key)=\(encoded)"
            }
            return nil
            }.joined(separator: "&").data(using: .utf8)

    }
    
    public var postData: Data? {
        if let data = _postData { return data }
        
        switch contentFormat {
        case .multipart:
            return multipartPostData(fromParams: params)
        case .json:
            return jsonPostData(fromParams: params)
        case .queryString:
            return queryStringPostData(fromParams: params)
        }
    }
}

public struct RequestBuilder {
    
    let request: URLRequest
    let params: [String: ParameterValue]
    let needsAuthentication: Bool
    let contentFormat: Request.ContentFormat
    let keyOrder: [String]
    let multipartBoundary: String

    public func addParameter(key: String, value: Encodable) -> RequestBuilder {
        var params = self.params
        params[key] = .simple(value: value)
        return RequestBuilder(request: request,
                              params: params,
                              needsAuthentication: needsAuthentication,
                              contentFormat: self.contentFormat,
                              keyOrder: keyOrder,
                              multipartBoundary: multipartBoundary)
    }
    
    public func addParameterAsJsonString(key: String, value: Any) -> RequestBuilder {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: value, options: []) else {
            preconditionFailure("Cannot create JSON from value")
        }
        guard let jsonString = String(data: jsonData, encoding: .utf8) else {
            preconditionFailure("Cannot encode jsonData into UTF8 string")
        }
        return addParameter(key: key, value: jsonString)
    }
    
    public func addFile(key: String, filename: String, fileContent: Data) -> RequestBuilder {
        var params = self.params
        params[key] = .file(name: filename, content: fileContent)
        return RequestBuilder(request: request,
                              params: params,
                              needsAuthentication: needsAuthentication,
                              contentFormat: self.contentFormat,
                              keyOrder: keyOrder,
                              multipartBoundary: multipartBoundary)
    }
    
    public func addParameters(_ extra: [String: Encodable]) -> RequestBuilder {
        var params = self.params
        for (key, value) in extra {
            params[key] = .simple(value: value)
        }
        return RequestBuilder(request: request,
                              params: params,
                              needsAuthentication: needsAuthentication,
                              contentFormat: self.contentFormat,
                              keyOrder: keyOrder,
                              multipartBoundary: multipartBoundary)
    }
    
    public func setNeedsAuthentication() -> RequestBuilder {
        return RequestBuilder(request: request,
                              params: params,
                              needsAuthentication: true,
                              contentFormat: contentFormat,
                              keyOrder: keyOrder,
                              multipartBoundary: multipartBoundary)
    }
    
    public func build() -> Request {
        return Request(request: request,
                              params: params,
                              needsAuthentication: needsAuthentication,
                              contentFormat: contentFormat,
                              keyOrder: keyOrder,
                              multipartBoundary: multipartBoundary)
    }
    
}

extension RequestBuilder {
    public init(_ path: String,
                serverConfiguration: LegacyWebServiceImpl.Configuration,
                method: Request.HTTPMethod = .post,
                contentFormat: Request.ContentFormat = .queryString,
                keyOrder: [String] = [],
                multipartBoundary: String = UUID().uuidString,
                length: Int? = nil,
                needsAuthentication: Bool = false,
                additionalHTTPHeaders: [String: String]? = nil,
                timeout: TimeInterval? = nil) {

        let base = serverConfiguration.environment.apiLegacyURL
        
        var components = URLComponents(string:path) ?? URLComponents()
        components.scheme = components.scheme ?? base.scheme
        components.host = components.host ?? base.host
        components.port = components.port ?? base.port
        var req = URLRequest(url: components.url!)
        additionalHTTPHeaders?.forEach { req.addValue($0.value, forHTTPHeaderField: $0.key) }
        req.httpMethod = method.rawValue
        if let timeout = timeout {
            req.timeoutInterval = timeout
        }
        request = req
        params = [:]
        self.needsAuthentication = needsAuthentication
        self.contentFormat = contentFormat
        self.keyOrder = keyOrder
        self.multipartBoundary = multipartBoundary
    }
}


private struct EncodableWrapper: Encodable {
    let value: Encodable
    init(_ value: Encodable) {
        self.value = value
    }
    
    func encode(to encoder: Encoder) throws {
        return try value.encode(to: encoder)
    }
}


extension URL {
            var hostWithPort: String? {
        guard let host = host, let port = port else { return self.host }
        return "\(host):\(port)"
    }
}
