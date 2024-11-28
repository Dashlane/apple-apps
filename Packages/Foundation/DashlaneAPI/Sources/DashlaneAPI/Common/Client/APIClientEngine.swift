import Foundation

#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public protocol APIClientEngine: Sendable {
  func post<Response: Decodable, Body: Encodable>(
    _ endpoint: Endpoint,
    body: Body,
    timeout: TimeInterval?,
    signer: RequestSigner?
  ) async throws -> Response

  func get<Response: Decodable>(
    _ endpoint: Endpoint,
    timeout: TimeInterval?,
    signer: RequestSigner?
  ) async throws -> Response
}

struct APIClientEngineImpl<Client: OpenAPISpecClient & APIClient, ErrorType: Error & Codable>:
  APIClientEngine
{
  let configuration: ClientConfiguration<Client>
  let session: URLSession
  let decoder = JSONDecoder()
  let encoder = JSONEncoder()

  init(
    configuration: ClientConfiguration<Client>,
    session: URLSession = URLSession(configuration: .ephemeral)
  ) {
    decoder.dateDecodingStrategy = .iso8601
    decoder.dataDecodingStrategy = .base64
    encoder.dateEncodingStrategy = .iso8601
    encoder.dataEncodingStrategy = .base64

    self.configuration = configuration
    self.session = session
  }

  func post<Response: Decodable, Body: Encodable>(
    _ endpoint: Endpoint,
    body: Body,
    timeout: TimeInterval?,
    signer: RequestSigner?
  ) async throws -> Response {
    var urlRequest = URLRequest(
      endpoint: endpoint,
      timeoutInterval: timeout,
      configuration: configuration)

    try urlRequest.updateBody(body, using: encoder)

    return try await perform(urlRequest, signer: signer)
  }

  func get<Response: Decodable>(
    _ endpoint: Endpoint,
    timeout: TimeInterval?,
    signer: RequestSigner?
  ) async throws -> Response {
    let urlRequest = URLRequest(
      endpoint: endpoint,
      timeoutInterval: timeout,
      configuration: configuration)
    return try await perform(urlRequest, signer: signer)
  }

  func perform<Response: Decodable>(_ request: URLRequest, signer: RequestSigner?) async throws
    -> Response
  {
    var urlRequest = request

    if let signer {
      try await urlRequest.sign(with: signer)
    }

    return try await session.response(from: urlRequest, using: decoder, errorType: ErrorType.self)
  }
}
