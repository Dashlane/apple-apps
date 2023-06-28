import Foundation
import DashTypes
import CoreNetworking

public protocol ProgressableNetworkingEngine {
    @discardableResult
    func sendProgressableRequest<R>(to endpoint: Endpoint,
                                    using method: DashTypes.HTTPMethod,
                                    params: [String: Encodable],
                                    contentFormat: DashTypes.ContentFormat,
                                    needsAuthentication: Bool,
                                    responseParser: R,
                                    file: File?,
                                    keyOrder: [String]?,
                                    completion: @escaping (Result<R.ParsedResponse, Swift.Error>) -> Void) -> URLSessionTask where R: ResponseParserProtocol
    func sendRequest<R>(to endpoint: Endpoint,
                        using method: DashTypes.HTTPMethod,
                        params: [String: Encodable],
                        contentFormat: DashTypes.ContentFormat,
                        needsAuthentication: Bool,
                        responseParser: R,
                        file: File?,
                        keyOrder: [String]?) async throws -> R.ParsedResponse where R: ResponseParserProtocol

    func load<A>(_ resource: CoreNetworking.Resource<A>) async throws -> A
}
