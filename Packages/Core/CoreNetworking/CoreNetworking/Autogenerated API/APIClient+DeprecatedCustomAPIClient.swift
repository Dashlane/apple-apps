import Foundation
@_exported import DashlaneAPI
import DashTypes

extension DeprecatedCustomAPIClient where Self: CustomAPIClientProvider {
    public func sendRequest<Input: Encodable, Output: Decodable>(to endpoint: Endpoint,
                                                                 using method: DashTypes.HTTPMethod,
                                                                 input: Input,
                                                                 timeout: TimeInterval?,
                                                                 completion: @escaping (Result<Output, Error>) -> Void) {

                let queue = Thread.isMainThread ? DispatchQueue.main : DispatchQueue.global()
        Task {
            do {
                let response: Output = try await sendRequest(to: endpoint, using: method, input: input, timeout: timeout)

                queue.async {
                    completion(.success(response))
                }

            } catch {
                queue.async {
                    completion(.failure(error))
                }
            }
        }
    }

    public func sendRequest<Input: Encodable, Output: Decodable>(to endpoint: Endpoint,
                                                                 using method: DashTypes.HTTPMethod,
                                                                 input: Input,
                                                                 timeout: TimeInterval?) async throws -> Output {
        do {
            return try await custom.perform(.init(method), to: endpoint.removingVersion(), body: input, timeout: timeout)
        } catch let error as DashlaneAPI.APIError {
                        throw DashTypes.APIErrorResponse(requestId: error.requestId, errors: error.errors.map {
                DashTypes.APIError(code: $0.code, message: $0.message, type: $0.type)
            })
        }
    }
}

extension AppAPIClient: DeprecatedCustomAPIClient { }
extension UserDeviceAPIClient: DeprecatedCustomAPIClient { }

extension CustomAPIClient.HTTPMethod {
    public init(_ method: DashTypes.HTTPMethod) {
        switch method {
        case .get:
            self = .get
        case .post:
            self = .post
        }
    }
}

extension Endpoint {
                fileprivate func removingVersion() -> String {
        return self.replacingOccurrences(of: "v1/", with: "")
    }
}
