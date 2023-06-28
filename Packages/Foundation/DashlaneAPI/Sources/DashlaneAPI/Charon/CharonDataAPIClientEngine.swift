import Foundation

public protocol CharonDataAPIClientEngine {
    func sendGetRequest<T: Codable>(url: URL) async throws -> CharonDataAPIClient.CharonResponse<T>
    func sendPostRequest(url: URL, body: Data, validateSuccess: Bool) async throws -> CharonDataAPIClient.CharonResponse<CharonDataAPIClient.Properties.Empty>
}

public struct CharonError: Error {
    public let message: String?
    public let statusCode: Int
}

struct CharonDataAPIClientEngineImpl: CharonDataAPIClientEngine {
    let session: URLSession
    let apiClientEngine: APIClientEngine
    let decoder = JSONDecoder()
    let apiURL: URL
    let signer: RequestSigner
    let additionalHeaders: [String: String]

    public init(apiURL: URL,
                apiClientEngine: APIClientEngine,
                signer: RequestSigner,
                additionalHeaders: [String: String],
                session: URLSession = URLSession(configuration: .ephemeral)) {
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
        self.apiURL = apiURL
        self.apiClientEngine = apiClientEngine
        self.signer = signer
        self.additionalHeaders = additionalHeaders
        self.session = session
    }

    @discardableResult
    func sendGetRequest<T: Codable>(url: URL) async throws -> CharonDataAPIClient.CharonResponse<T> {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setHeaders(additionalHeaders)

        return try await signAndSendRequest(request: request)
    }

    @discardableResult
    func sendPostRequest(url: URL, body: Data, validateSuccess: Bool = true) async throws -> CharonDataAPIClient.CharonResponse<CharonDataAPIClient.Properties.Empty> {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        request.setHeaders(additionalHeaders)

        return try await signAndSendRequest(request: request, validateSuccess: validateSuccess)
    }

    private func signAndSendRequest<T: Codable>(request: URLRequest, validateSuccess: Bool = true) async throws -> CharonDataAPIClient.CharonResponse<T> {
        var signedRequest = request
        try signedRequest.sign(with: signer, timeshift: try await apiClientEngine.timeshift)
        let data: CharonDataAPIClient.CharonResponse<T> = try await session.charonResponse(from: signedRequest, using: decoder, validateSuccess: validateSuccess)
        return data
    }

}

fileprivate extension URLSession {

    func charonResponse<T: Codable>(from urlRequest: URLRequest, using decoder: JSONDecoder, validateSuccess: Bool = true) async throws -> CharonDataAPIClient.CharonResponse<T> {
        let (data, response) = try await data(for: urlRequest)

        guard let urlResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        let decodedResponse = try decoder.decode(CharonDataAPIClient.CharonResponse<T>.self, from: data)
                        switch urlResponse.statusCode {
        case ~200..<300:
            if validateSuccess && decodedResponse.success != true {
                throw CharonError(message: decodedResponse.error, statusCode: urlResponse.statusCode)
            }
            return decodedResponse
        default:
            throw CharonError(message: decodedResponse.error, statusCode: urlResponse.statusCode)
        }
    }
}
