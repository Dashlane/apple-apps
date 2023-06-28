import Foundation

public protocol DeprecatedCustomAPIClient {
        func sendRequest<Input: Encodable, Output: Decodable>(to endpoint: Endpoint,
                                                          using method: HTTPMethod,
                                                          input: Input,
                                                          timeout: TimeInterval?,
                                                          completion: @escaping (Result<Output, Error>) -> Void)

    func sendRequest<Input: Encodable, Output: Decodable>(to endpoint: Endpoint,
                                                          using method: HTTPMethod,
                                                          input: Input,
                                                          timeout: TimeInterval?) async throws -> Output
}

public extension DeprecatedCustomAPIClient {
    func sendRequest<Input: Encodable, Output: Decodable>(to endpoint: Endpoint,
                                                          using method: HTTPMethod,
                                                          input: Input,
                                                          completion: @escaping (Result<Output, Error>) -> Void) {
        sendRequest(to: endpoint, using: method, input: input, timeout: nil, completion: completion)
    }

    func sendRequest<Input: Encodable, Output: Decodable>(to endpoint: Endpoint,
                                                          using method: HTTPMethod,
                                                          input: Input) async throws -> Output {
        try await sendRequest(to: endpoint, using: method, input: input, timeout: nil)
    }

        func sendRequestSynchronously<Input: Encodable,
        Output: Decodable>(to endpoint: Endpoint,
                           using method: HTTPMethod,
                           input: Input?, timeout: TimeInterval? = nil) throws -> Output {
        let requestSemaphore = DispatchSemaphore(value: 0)
        var receivedResult: Result<Output, Error>?
        self.sendRequest(to: endpoint,
                         using: method,
                         input: input,
                         timeout: timeout) { (result: Result<Output, Error>) in
                            receivedResult = result
                            requestSemaphore.signal()
        }
        requestSemaphore.wait()
        return try receivedResult!.get()
    }

}

public extension DeprecatedCustomAPIClient {
    func sendRequest<Input: Encodable, Output: Decodable>(to endpoint: Endpoint,
                                                          using method: HTTPMethod,
                                                          input: Input,
                                                          timeout: TimeInterval?) async throws -> Output {
        return try await withCheckedThrowingContinuation({ continuation in
            sendRequest(to: endpoint, using: method, input: input, timeout: timeout) { result in
                continuation.resume(with: result)
            }
        })

    }
}

public struct DeprecatedCustomAPIClientMock: DeprecatedCustomAPIClient {
    enum MockingError: Error {
        case typeMismatch(typeExpected: String, typeReceived: String)
    }
    let result: Result<() -> Any, Error>

    public var catchInput: ((Any) -> Void)?

    public init(_ response: @escaping () -> Any) {
        self.result = .success(response)
    }

    public init(error: Error) {
        self.result = .failure(error)
    }

    public func sendRequest<Input, Output>(to endpoint: Endpoint, using method: HTTPMethod, input: Input, timeout: TimeInterval?, completion: @escaping (Result<Output, Error>) -> Void) where Input: Encodable, Output: Decodable {

        self.catchInput?(input)

        completion(result.flatMap { response in
            let response = response()
            guard let response = response as? Output else {
                let error = MockingError.typeMismatch(typeExpected: String(describing: Output.self), typeReceived: String(describing: type(of: type(of: response))))
                fatalError("type mismatch expected:\(Output.self) received:\(type(of: response)). Error: \(error)")
            }
            return .success(response)
        })
    }
}

public extension DeprecatedCustomAPIClient where Self == DeprecatedCustomAPIClientMock {
    static func mock(with response: @escaping () -> Any) -> DeprecatedCustomAPIClientMock {
        DeprecatedCustomAPIClientMock(response)
    }

    static func mock(_ response: Any) -> DeprecatedCustomAPIClientMock {
        DeprecatedCustomAPIClientMock {
            response
        }
    }

    static func mock(error: Error) -> DeprecatedCustomAPIClientMock {
        DeprecatedCustomAPIClientMock(error: error)
    }

    static var fake: DeprecatedCustomAPIClientMock {
        .mock("")
    }
}
