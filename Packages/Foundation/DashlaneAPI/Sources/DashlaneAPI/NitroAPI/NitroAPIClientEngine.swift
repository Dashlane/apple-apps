import Foundation

public protocol NitroAPIClientEngine {
    func post<Response: Decodable, Body: Encodable>(_ endpoint: Endpoint,
                                                           body: Body) async throws -> Response
    func get<Response: Decodable>(_ endpoint: Endpoint,
                                         timeout: TimeInterval?) async throws -> Response
}

public struct NitroAPIClientEngineImp: NitroAPIClientEngine {
    let session: URLSession
    let decoder = JSONDecoder()
    let encoder = JSONEncoder()
    let environment: NitroEnvironment
    let additionalHeaders: [String: String]
    
    public init(environment: NitroEnvironment = .production, info: APIConfiguration.Info) throws {
        self.session = URLSession(configuration: .ephemeral)
        self.environment = environment
        additionalHeaders = try Self.makeAdditionalHeaders(info: info, environment: environment)
    }
    
    public func post<Response: Decodable, Body: Encodable>(_ endpoint: Endpoint,
                                                           body: Body) async throws -> Response {
        var urlRequest = URLRequest(endpoint: endpoint,
                                    environment: environment,
                                    additionalHeaders: additionalHeaders)
        try urlRequest.updateBody(body, using: encoder)
        return try await session.response(from: urlRequest, using: decoder)
    }
    
    public func get<Response: Decodable>(_ endpoint: Endpoint,
                                         timeout: TimeInterval?) async throws -> Response {
        let urlRequest = URLRequest(endpoint: endpoint,
                                    environment: environment,
                                    additionalHeaders: additionalHeaders)
        return try await session.response(from: urlRequest, using: decoder)
    }
}

extension NitroAPIClientEngineImp {
    static func makeAdditionalHeaders(info: APIConfiguration.Info, environment: NitroEnvironment) throws -> [String: String] {
        let headers =  [
            "dashlane-client-agent": try JSONEncoder().encodeString(DashlaneClientAgent(info: info))
        ]

        switch environment {
        case .production:
            return headers
#if DEBUG
        case let .staging(info):
            let cloudFare =  [
                "CF-Access-Client-Id": info.cloudfareIdentifier,
                "CF-Access-Client-Secret": info.cloudfareSecret
            ]
            return headers.merging(cloudFare) { left, _ in return left }
#endif
        }
    }
}
