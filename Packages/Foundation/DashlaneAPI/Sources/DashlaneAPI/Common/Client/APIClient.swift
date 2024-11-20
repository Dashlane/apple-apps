import Foundation

protocol APIClient: Sendable {
  var signer: RequestSigner? { get }
  var engine: APIClientEngine { get }
}

extension APIClient {
  var signer: RequestSigner? {
    return nil
  }
}

extension APIClient {
  func post<Response: Decodable, Body: Encodable>(
    _ endpoint: Endpoint,
    body: Body,
    timeout: TimeInterval? = nil
  ) async throws -> Response {
    return try await engine.post(endpoint, body: body, timeout: timeout, signer: signer)
  }

  func get<Response: Decodable>(_ endpoint: Endpoint, timeout: TimeInterval? = nil) async throws
    -> Response
  {
    return try await engine.get(endpoint, timeout: timeout, signer: signer)
  }
}
