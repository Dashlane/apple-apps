import Foundation

public protocol APIClientEngine {
        func post<Response: Decodable, Body: Encodable>(_ endpoint: Endpoint,
                                                    body: Body,
                                                    timeout: TimeInterval?,
                                                    signer: RequestSigner) async throws -> Response

        func get<Response: Decodable>(_ endpoint: Endpoint,
                                  timeout: TimeInterval?,
                                  signer: RequestSigner) async throws -> Response

        var timeshift: TimeInterval { get async throws }
}

actor APIClientEngineImpl: APIClientEngine {
    let configuration: APIConfiguration
    let session: URLSession
    let decoder = JSONDecoder()
    let encoder = JSONEncoder()

    var timeshiftProvider: TimeshiftProvider {
        TimeshiftProvider(configuration: configuration, additionalHeaders: configuration.additionalHeaders, session: session, decoder: decoder)
    }
    var currentTimeshiftRequestTask: Task<TimeInterval, Error>?
    var currentTimeshift: TimeInterval?
    var timeshift: TimeInterval {
        get async throws {
            if let currentTimeshift {
                return currentTimeshift
            } else if let task = currentTimeshiftRequestTask {
               return try await task.value
            } else {
                let task = Task {
                    defer {
                        currentTimeshiftRequestTask = nil
                    }
                    let timeshift = try await timeshiftProvider.fetch()
                    currentTimeshift = timeshift
                    return timeshift
                }
                currentTimeshiftRequestTask = task
                return try await task.value
            }
        }
    }

    init(configuration: APIConfiguration, session: URLSession = URLSession(configuration: .ephemeral)) {
        decoder.dateDecodingStrategy = .secondsSince1970
        encoder.dateEncodingStrategy = .secondsSince1970

        self.configuration = configuration
        self.session = session
    }

    func post<Response: Decodable, Body: Encodable>(_ endpoint: Endpoint,
                                                    body: Body,
                                                    timeout: TimeInterval?,
                                                    signer: RequestSigner) async throws -> Response {
        var urlRequest = URLRequest(endpoint: endpoint,
                                    timeoutInterval: timeout,
                                    configuration: configuration)

        try urlRequest.updateBody(body, using: encoder)

        return try await perform(urlRequest, signer: signer)
    }

    func get<Response: Decodable>(_ endpoint: Endpoint,
                                  timeout: TimeInterval?,
                                  signer: RequestSigner) async throws -> Response {
        let urlRequest = URLRequest(endpoint: endpoint,
                                    timeoutInterval: timeout,
                                    configuration: configuration)
        return try await perform(urlRequest, signer: signer)
    }

    func perform<Response: Decodable>(_ request: URLRequest, signer: RequestSigner) async throws -> Response {
        var urlRequest = request
        try urlRequest.sign(with: signer, timeshift: try await timeshift)

        return try await session.response(from: urlRequest, using: decoder)
    }
}
